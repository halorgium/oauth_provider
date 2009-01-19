require 'dm-core'
require 'dm-validations'

module OAuthProvider
  module Backends
    class DataMapper < Abstract
      def initialize(repository = :default)
        @repository = repository
      end

      def add_consumer(consumer)
        with_repository do
          Consumer.create(:name => consumer.name,
                          :callback => consumer.callback,
                          :shared_key => consumer.shared_key,
                          :secret_key => consumer.secret_key)
        end
      end

      def fetch_consumer(shared_key)
        consumer = consumer_for(shared_key)
        consumer && consumer.to_oauth(provider)
      end

      def create_user_request(user_request)
        with_repository do
          if consumer = consumer_for(user_request.consumer.shared_key)
            consumer.user_requests.create(:shared_key => user_request.shared_key,
                                          :secret_key => user_request.secret_key)
          end
        end
      end

      def fetch_user_request(shared_key)
        user_request = user_request_for(shared_key)
        user_request && user_request.to_oauth(provider)
      end

      def update_user_request(user_request, user_access)
        if u = user_request_for(user_request.shared_key)
          u.user_access = user_access_for(user_access.shared_key) || raise("Coudlnt fijselfij")
          u.save || raise("Couldn't save user access")
        end
      end

      def create_user_access(user_access)
        with_repository do
          if consumer = consumer_for(user_access.consumer.shared_key)
            u = consumer.user_accesses.create(:shared_key => user_access.shared_key,
                                          :secret_key => user_access.secret_key)
          else
            raise ConsumerNotFound.new(user_access.consumer.shared_key)
          end
        end
      end

      def fetch_user_access(shared_key)
        with_repository do
          user_access = UserAccess.first(:shared_key => shared_key)
          user_access && user_access.to_oauth(provider)
        end
      end

      private
      def with_repository(&block)
        ::DataMapper.repository(@repository) do
          yield
        end
      end

      def consumer_for(shared_key)
        with_repository do
          Consumer.first(:shared_key => shared_key)
        end
      end

      def user_request_for(shared_key)
        with_repository do
          UserRequest.first(:shared_key => shared_key)
        end
      end

      def user_access_for(shared_key)
        with_repository do
          UserAccess.first(:shared_key => shared_key)
        end
      end
    end
  end
end

require 'oauth_provider/backends/data_mapper/consumer'
require 'oauth_provider/backends/data_mapper/user_request'
require 'oauth_provider/backends/data_mapper/user_access'
