module OAuthProvider
  module Backends
    class Abstract
      def provider
        @provider ||= Provider.new(self)
      end

      def add_consumer(provider, callback, token)
        consumer = Consumer.new(self, provider, callback, token)
        create_consumer(consumer)
        consumer
      end

      def create_consumer(consumer)
        raise NotImplemented, "Implement #create_consumer in #{self.class}"
      end
      protected :create_consumer

      def find_consumer(shared_key)
        raise NotImplemented, "Implement #find_consumer in #{self.class}"
      end

      def save_consumer(shared_key)
        raise NotImplemented, "Implement #save_consumer in #{self.class}"
      end

      def destroy_consumer(shared_key)
        raise NotImplemented, "Implement #destroy_consumer in #{self.class}"
      end

      def add_user_request(consumer, authorized, token)
        user_request = UserRequest.new(self, consumer, authorized, token)
        create_user_request(user_request)
        user_request
      end

      def create_user_request(user_request)
        raise NotImplemented, "Implement #create_user_request in #{self.class}"
      end
      protected :create_user_request

      def find_user_request(shared_key)
        raise NotImplemented, "Implement #find_user_request in #{self.class}"
      end

      def save_user_request(user_request)
        raise NotImplemented, "Implement #save_user_request in #{self.class}"
      end

      def destroy_user_request(user_request)
        raise NotImplemented, "Implement #destroy_user_request in #{self.class}"
      end

      def add_user_access(user_request, token)
        user_access = UserAccess.new(self, user_request.consumer, user_request.shared_key, token)
        create_user_access(user_access)
        destroy_user_request(user_request)
        user_access
      end

      def create_user_access(user_access)
        raise NotImplemented, "Implement #create_user_access in #{self.class}"
      end
      protected :create_user_access

      def find_user_access(shared_key)
        raise NotImplemented, "Implement #find_user_access in #{self.class}"
      end

      def destroy_user_access(user_access)
        raise NotImplemented, "Implement #destroy_user_access in #{self.class}"
      end
    end
  end
end
