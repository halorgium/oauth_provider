module OAuthProvider
  module Backends
    class DataMapper
      class UserAccess
        include ::DataMapper::Resource

        property :id, Serial
        property :consumer_id, Integer, :nullable => false
        property :request_shared_key, String, :nullable => false
        property :shared_key, String, :unique => true, :nullable => false
        property :secret_key, String, :unique => true, :nullable => false

        belongs_to :consumer

        def token
          OAuthProvider::Token.new(shared_key, secret_key)
        end

        def to_oauth(backend)
          OAuthProvider::UserAccess.new(backend, consumer.to_oauth(backend), request_shared_key, token)
        end
      end
    end
  end
end
