require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    # Authenticate to force.com utilizing OAuth 2.0 and retrieve
    # basic user information.
    #
    # @example Basic Usage
    #   use OmniAuth::Strategies::Force, 'consumer_key', 'consumer_secret'
    class Force < OAuth2
      # @param [Rack Application] app standard middleware application parameter
      # @param [String] app_id the application id
      # @param [String] app_secret the application secret
      def initialize(app, consumer_key, consumer_secret, options = {})
        options[:site] = 'https://login.salesforce.com/'
        options[:authorize_path] = '/services/oauth2/authorize'
        options[:access_token_path] = '/services/oauth2/token'

        super(app, :force, consumer_key, consumer_secret, options)
      end

      def user_data
        @data ||= MultiJson.decode(@access_token.get(@access_token['id']))
      end

      # Monkey patch scheme for callback url
      def full_host
        uri = URI.parse(request.url)
        uri.path = ''
        uri.query = nil
        uri.scheme = request.env['HTTP_X_FORWARDED_PROTO'] || request.scheme
        uri.to_s
      end

      def request_phase
        options[:response_type] ||= "code"
        super
      end

      def get_access_token(verifier)
        access_token = client.web_server.get_access_token(
            verifier,
            :redirect_uri => callback_url,
            :grant_type => 'authorization_code').tap do |token|
          token.token_param = 'oauth_token'
        end

        access_token
      end

      def callback_phase
        if request.params['error'] || request.params['error_reason']
          raise CallbackError.new(request.params['error'], request.params['error_description'] || request.params['error_reason'], request.params['error_uri'])
        end

        @access_token = get_access_token(request.params['code'])
        @env['omniauth.auth'] = auth_hash
        call_app!
      rescue ::OAuth2::HTTPError, ::OAuth2::AccessDenied, CallbackError => e
        fail!(:invalid_credentials, e)
      end

      def user_info
        {
          'nickname' => user_data['nick_name'],
          'email' => user_data['email'],
          'name' => user_data['display_name'],
          'urls' => {
            'Force' => user_data['urls']['profile'],
          }
        }
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'uid' => user_data['user_id'],
          'user_info' => user_info,
          'extra' => {'user_hash' => user_data},
          'credentials' => { 'instance_url' => @access_token['instance_url'] }
        })
      end
    end
  end
end
