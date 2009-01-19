module OAuthProvider
  module Backends
    class DataMapper
      class UserRequest
        include ::DataMapper::Resource

        property :id, Serial
        property :consumer_id, Integer, :nullable => false
        property :shared_key, String, :unique => true, :nullable => false
        property :secret_key, String, :unique => true, :nullable => false
        property :user_access_id, Integer

        belongs_to :consumer
        belongs_to :user_access, :class_name => "UserAccess"

        def token
          OAuthProvider::Token.new(shared_key, secret_key)
        end

        def to_oauth(provider)
          OAuthProvider::UserRequest.new(consumer.to_oauth(provider), token, user_access && user_access.to_oauth(provider))
        end
      end
    end
  end
end
