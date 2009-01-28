require 'oauth'
require 'oauth/server'
require 'oauth/signature'

module OAuthProvider
  class Error < StandardError; end
  class NotImplemented < Error; end
  class ConsumerNotFound < Error
    def initialize(shared_key)
      super("No Consumer with shared key: #{shared_key.inspect}")
    end
  end
  class UserRequestNotFound < Error
    def initialize(shared_key)
      super("No User Request with shared key: #{shared_key.inspect}")
    end
  end
  class UserAccessNotFound < Error
    def initialize(shared_key)
      super("No User Access with shared key: #{shared_key.inspect}")
    end
  end
  class UserRequestNotAuthorized < Error
    def initialize(user_request)
      super("The User Request is not yet authorized by the User: #{user_request.shared_key.inspect}")
    end
  end
  class VerficationFailed < Error; end
  class IncompleteToken < Error; end

  class DuplicateCallback < Error
    def initialize(consumer)
      super("The callback #{consumer.callback.inspect} is already used by another consumer")
    end
  end

  def self.create(backend_type, *args)
    Backends.for(backend_type, *args).provider
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
