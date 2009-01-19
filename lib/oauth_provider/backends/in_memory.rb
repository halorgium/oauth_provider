module OAuthProvider
  module Backends
    class InMemory < Abstract
      def initialize
        @consumers = []
      end

      def create_consumer(name, callback, shared_key, secret_key)
        raise "Consumer already exists" if find_consumer(shared_key)
        c = Consumer.new(name, callback, shared_key, secret_key, [])
        @consumers << c
      end

      def fetch_consumer(shared_key)
        if c = find_consumer(shared_key)
          [c.name, c.callback, c.shared_key, c.secret_key]
        end
      end

      def create_request_token(consumer_shared_key, shared_key, secret_key)
        if c = find_consumer(consumer_shared_key)
          c.tokens << Token.new(shared_key, secret_key, nil, nil)
        else
          raise "No consumer with shared key #{consumer_shared_key.inspect} found"
        end
      end

      def fetch_request_token(consumer_shared_key, shared_key)
        if t = find_request_token(consumer_shared_key, shared_key)
          [t.request_shared_key, t.request_secret_key]
        end
      end

      def create_access_token(consumer_shared_key, request_shared_key, shared_key, secret_key)
        if t = find_request_token(consumer_shared_key, request_shared_key)
          t.access_shared_key = shared_key
          t.access_secret_key = secret_key
        else
          raise "No request token with shared key #{consumer_shared_key.inspect} found"
        end
      end

      def fetch_access_token(consumer_shared_key, shared_key)
        if t = find_access_token(consumer_shared_key, shared_key)
          [t.request_shared_key, t.request_secret_key, t.access_shared_key, t.access_secret_key]
        end
      end

      private
      def find_consumer(shared_key)
        @consumers.find {|c| c.shared_key == shared_key}
      end

      def find_request_token(consumer_shared_key, shared_key)
        if c = find_consumer(consumer_shared_key)
          c.tokens.find {|t| t.request_shared_key == shared_key}
        end
      end

      def find_access_token(consumer_shared_key, shared_key)
        if c = find_consumer(consumer_shared_key)
          c.tokens.find {|t| t.access_shared_key == shared_key}
        end
      end

      class Consumer < Struct.new(:name, :callback, :shared_key, :secret_key, :tokens); end
      class Token < Struct.new(:request_shared_key, :request_secret_key, :access_shared_key, :access_secret_key); end
    end
  end
end
