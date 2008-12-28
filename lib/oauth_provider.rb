require 'oauth' # Generic OAuth code
require 'oauth/server' # Generic OAuth server
require 'oauth/signature' # To build and verify signatures
require 'oauth/request_proxy/rack_request' # To extract data from sinatra request objects

module OAuthProvider
  SERVER_BASE = 'http://localhost:4567' unless defined?(SERVER_BASE)
end

$:.unshift File.dirname(__FILE__)

require 'oauth_provider/fixes'
require 'oauth_provider/provider'
require 'oauth_provider/token_methods'
require 'oauth_provider/request_token'
require 'oauth_provider/access_token'
require 'oauth_provider/consumer'
