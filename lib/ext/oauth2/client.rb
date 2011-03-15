require 'oauth2/client'

# Monkey patch to correct status handling
class OAuth2::Client
  alias :old_request :request
  def request(verb, url, params = {}, headers = {})
    old_request(verb, url, params, headers)
  rescue OAuth2::HTTPError => e
    if e.response.status == 302
      url = e.response.headers['location']
      retry
    else
      raise e
    end
  end
end
