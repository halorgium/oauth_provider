module OAuthProvider
  module Backends
    class DataMapper
      class UserRequest
        include ::DataMapper::Resource

        property :id, Serial
        property :consumer_id, Integer, :nullable => false
        property :authorized, Boolean, :default => false, :nullable => false
        property :shared_key, String, :unique => true, :nullable => false
        property :secret_key, String, :unique => true, :nullable => false

        belongs_to :consumer , :class_name => '::OAuthProvider::Backends::DataMapper::Consumer'

        def token
          OAuthProvider::Token.new(shared_key, secret_key)
        end

        def to_oauth(backend)
          OAuthProvider::UserRequest.new(backend, consumer.to_oauth(backend), authorized, token)
        end
      end
    end
  end
end
