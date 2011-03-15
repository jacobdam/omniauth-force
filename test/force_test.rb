require "test_helper"

class ForceTest < ActiveSupport::TestCase
  include Rack::Test::Methods

  def dummy_app
    @dummy_app ||= lambda { |env| [200, {}, ["Dummy app"]] }
  end

  def app
    @app ||= OmniAuth::Strategies::Force.new(dummy_app, 'force-api-key', 'force-api-secret')
  end

  test "request phase should redirect to force login page with correct params" do
    get '/auth/force'
    assert last_response.redirect?

    uri = URI.parse(last_response.location)
    assert_equal uri.scheme, 'https'
    assert_equal uri.host, 'login.salesforce.com'
    assert_equal uri.path, '/services/oauth2/authorize'

    params = CGI::parse(uri.query)
    assert_equal params['client_id'], ['force-api-key']
    assert_equal params['redirect_uri'], ['http://example.org/auth/force/callback']
    assert_equal params['response_type'], ['code']
    assert_equal params['type'], ['web_server']
  end

  test "callback phase should " do
    sf_token = {
      'instance_url' => 'http://instance',
      'id' => 'http://instance/id/123',
      'access_token' => 'token123',
    }
    sf_user_data = {
      'user_id' => 123,
      'nick_name' => 123,
      'email' => 123,
      'display_name' => 123,
      'urls' => {
        'profile' => 'http://instance/profile/123'
      },
    }
    auth_hash = nil
    @dummy_app = lambda do |env|
      auth_hash = env['omniauth.auth']
      [200, {}, ["Dummy app"]]
    end

    connection = Faraday.new do |builder|
      builder.adapter :test do |stub|
        stub.post('/services/oauth2/token') {[ 200, {}, MultiJson.encode(sf_token) ]}
        stub.get('/id/123?oauth_token=token123') {[ 200, {}, MultiJson.encode(sf_user_data) ]}
      end
    end


    app.client.connection = connection
    get '/auth/force/callback?code=code123'

    assert_equal({
      "provider" => "force",
      "uid" => 123,
      "credentials" => {
        "token" => "token123",
        "instance_url" => "http://instance"
      },
      "user_info" => {
        "nickname"=>123,
        "email"=>123,
        "name"=>123,
        "urls"=>{
          "Force"=>"http://instance/profile/123"
        }
      },
      "extra"=>{
        "user_hash"=>sf_user_data
      }
    }, auth_hash)
  end
end