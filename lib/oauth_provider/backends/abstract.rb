module OAuthProvider
  module Backends
    class Abstract
      def create_consumer(name, shared_key, secret_key, callback)
        raise NotImplemented, "Implement #create_consumer in #{self.class}"
      end

      def fetch_consumer(shared_key)
        raise NotImplemented, "Implement #fetch_consumer in #{self.class}"
      end

      def create_request_token(consumer_shared_key, shared_key, secret_key)
        raise NotImplemented, "Implement #create_request_token in #{self.class}"
      end

      def fetch_request_token(consumer_shared_key, shared_key)
        raise NotImplemented, "Implement #fetch_request_token in #{self.class}"
      end

      def create_access_token(consumer_shared_key, request_shared_key, shared_key, secret_key)
        raise NotImplemented, "Implement #create_access_token in #{self.class}"
      end

      def fetch_access_token(consumer_shared_key, shared_key)
        raise NotImplemented, "Implement #fetch_access_token in #{self.class}"
      end
    end
  end
end
