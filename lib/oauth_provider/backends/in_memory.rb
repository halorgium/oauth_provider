module OAuthProvider
  module Backends
    class InMemory < Abstract
      def initialize
        @consumers, @user_requests, @user_accesses = [], [], []
      end

      def add_consumer(consumer)
        @consumers << consumer
      end

      def fetch_consumer(shared_key)
        @consumers.find {|x| x.shared_key == shared_key}
      end

      def create_user_request(user_request)
        @user_requests << user_request
      end

      def fetch_user_request(shared_key)
        @user_requests.find {|x| x.shared_key == shared_key}
      end

      def update_user_request(user_request, user_access)
      end

      def create_user_access(user_access)
        @user_accesses << user_access
      end

      def fetch_user_access(shared_key)
        @user_accesses.find {|x| x.shared_key == shared_key}
      end
    end
  end
end
