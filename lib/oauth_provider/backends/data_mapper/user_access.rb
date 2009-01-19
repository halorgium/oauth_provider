module OAuthProvider
  module Backends
    class DataMapper
      class UserAccess
        include ::DataMapper::Resource

        property :id, Serial
        property :consumer_id, Integer, :nullable => false
        property :shared_key, String, :unique => true, :nullable => false
        property :secret_key, String, :unique => true, :nullable => false

        belongs_to :consumer

        def token
          OAuthProvider::Token.new(shared_key, secret_key)
        end

        def to_oauth(provider)
          OAuthProvider::UserAccess.new(consumer.to_oauth(provider), token)
        end
      end
    end
  end
end
