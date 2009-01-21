module OAuthProvider
  module Backends
    class InMemory < Abstract
      def initialize
        @consumers, @user_requests, @user_accesses = [], [], []
      end
      attr_reader :consumers

      def create_consumer(consumer)
        raise DuplicateCallback.new(consumer) if @consumers.any? {|c| c.callback == consumer.callback}
        @consumers << consumer
      end

      def find_consumer(shared_key)
        @consumers.find {|x| x.shared_key == shared_key}
      end

      def destroy_consumer(consumer)
        @consumers.delete(consumer)
      end

      def create_user_request(user_request)
        @user_requests << user_request
      end

      def find_user_request(shared_key)
        @user_requests.find {|x| x.shared_key == shared_key}
      end

      def save_user_request(user_request)
        @user_requests.find {|x| x == user_request} || raise
      end

      def destroy_user_request(user_request)
        @user_requests.delete(user_request)
      end

      def create_user_access(user_access)
        @user_accesses << user_access
      end

      def find_user_access(shared_key)
        @user_accesses.find {|x| x.shared_key == shared_key}
      end
    end
  end
end
