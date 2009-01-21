require 'dm-core'
require 'dm-validations'

module OAuthProvider
  module Backends
    class DataMapper < Abstract
      def initialize(repository = :default)
        @repository = repository
      end

      def consumers
        with_repository do
          Consumer.all.map do |c|
            c.to_oauth(self)
          end
        end
      end

      def create_consumer(consumer)
        with_repository do
          raise DuplicateCallback.new(consumer) if Consumer.first(:callback => consumer.callback)
          model = Consumer.new(:callback => consumer.callback,
                               :shared_key => consumer.shared_key,
                               :secret_key => consumer.secret_key)
          model.save || raise("Failed to create Consumer: #{model.inspect}, #{model.errors.inspect}")
        end
      end

      def find_consumer(shared_key)
        consumer = consumer_for(shared_key)
        consumer && consumer.to_oauth(self)
      end

      def destroy_consumer(consumer)
        consumer = consumer_for(consumer.shared_key)
        consumer && consumer.destroy
      end

      def create_user_request(user_request)
        with_repository do
          if consumer = consumer_for(user_request.consumer.shared_key)
            consumer.user_requests.create(:shared_key => user_request.shared_key,
                                          :secret_key => user_request.secret_key)
          end
        end
      end

      def find_user_request(shared_key)
        user_request = user_request_for(shared_key)
        user_request && user_request.to_oauth(self)
      end

      def save_user_request(user_request)
        if model = user_request_for(user_request.shared_key)
          model.authorized = user_request.authorized?
          model.save || raise("Failed to save UserRequest: #{user_request.shared_key}, #{model.errors.inspect}")
        end
      end

      def destroy_user_request(user_request)
        user_request = user_request_for(user_request.shared_key)
        user_request && user_request.destroy
      end

      def create_user_access(user_access)
        with_repository do
          if consumer = consumer_for(user_access.consumer.shared_key)
            u = consumer.user_accesses.create(:request_shared_key => user_access.request_shared_key,
                                              :shared_key => user_access.shared_key,
                                              :secret_key => user_access.secret_key)
          else
            raise ConsumerNotFound.new(user_access.consumer.shared_key)
          end
        end
      end

      def find_user_access(shared_key)
        with_repository do
          user_access = UserAccess.first(:shared_key => shared_key)
          user_access && user_access.to_oauth(self)
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
