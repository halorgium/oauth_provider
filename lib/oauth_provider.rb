require 'rubygems'
gem 'oauth'

require 'oauth'
require 'oauth/server'
require 'oauth/signature'

module OAuthProvider
  class Error < StandardError; end
  class ConsumerNotFound < Error
    def initialize(shared_key)
      super("No Consumer with shared key: #{shared_key.inspect}")
    end
  end
  class UserRequestNotFound < Error; end
  class UserAccessNotFound < Error; end
  class VerficationFailed < Error; end

  def self.create(*args)
    Provider.create(*args)
  end
end

$:.unshift File.dirname(__FILE__)

require 'oauth_provider/fixes'
require 'oauth_provider/token'
require 'oauth_provider/provider'
require 'oauth_provider/consumer'
require 'oauth_provider/user_request'
require 'oauth_provider/user_access'

require 'oauth_provider/backends'
require 'oauth_provider/backends/abstract'
