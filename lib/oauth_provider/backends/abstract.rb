module OAuthProvider
  module Backends
    class Abstract
      class NotImplemented < StandardError; end

      attr_accessor :provider

      def create_consumer(consumer)
        raise NotImplemented, "Implement #create_consumer in #{self.class}"
      end

      def fetch_consumer(shared_key)
        raise NotImplemented, "Implement #fetch_consumer in #{self.class}"
      end

      def create_user_request(user_request)
        raise NotImplemented, "Implement #create_user_request in #{self.class}"
      end

      def fetch_user_request(shared_key)
        raise NotImplemented, "Implement #fetch_user_request in #{self.class}"
      end

      def update_user_request(user_request, user_access)
        raise NotImplemented, "Implement #update_user_request in #{self.class}"
      end

      def create_user_access(user_access)
        raise NotImplemented, "Implement #create_user_access in #{self.class}"
      end

      def fetch_user_access(shared_key)
        raise NotImplemented, "Implement #fetch_user_access in #{self.class}"
      end
    end
  end
end
