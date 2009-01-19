module OAuthProvider
  class Provider
    def self.create(backend_type, *args)
      new(Backends.for(backend_type, *args))
    end

    def initialize(backend)
      @backend = backend
      @backend.provider = self
    end
    attr_reader :backend

    def add_consumer(name, callback)
      consumer = Consumer.new(self, name, callback, Token.generate)
      @backend.add_consumer(consumer)
      consumer
    end

    def consumer_for(shared_key)
      @backend.fetch_consumer(shared_key) ||
        raise(ConsumerNotFound.new(shared_key))
    end

    def issue_request(request)
      consumer = verify(request, :consumer)
      add_user_request(consumer)
    end

    def add_user_request(consumer)
      user_request = UserRequest.new(consumer, Token.generate, nil)
      @backend.create_user_request(user_request)
      user_request
    end

    def user_request_for(shared_key)
      @backend.fetch_user_request(shared_key) ||
        raise(UserRequestNotFound, "No UserRequest with shared key: #{shared_key.inspect}")
    end

    def authorize_request(shared_key)
      user_request = user_request_for(shared_key)
      add_user_access(user_request)
    end

    def upgrade_request(request)
      user_request = verify(request, :request)
      user_request.user_access
    end

    def add_user_access(user_request)
      user_access = UserAccess.new(user_request.consumer, Token.generate)
      @backend.create_user_access(user_access)
      @backend.update_user_request(user_request, user_access)
      user_access
    end

    def user_access_for(shared_key)
      @backend.fetch_user_access(shared_key) ||
        raise(UserAccessNotFound, "No UserAccess with shared key: #{shared_key.inspect}")
    end

    def validate_token(request)
      verify(request, :access)
    end

    private
    def verify(request, type, &block)
      result = nil

      signature = OAuth::Signature.build(request) do |shared_key,consumer_shared_key|
        consumer = consumer_for(consumer_shared_key)
        case type
        when :request
          result = user_request_for(shared_key)
          [result.secret_key, consumer.secret_key]
        when :access
          result = user_access_for(shared_key)
          [result.secret_key, consumer.secret_key]
        when :consumer
          result = consumer
          [nil, consumer.secret_key]
        else
          raise ArgumentError, "Type should be one of :request, :access or :consumer"
        end
      end

      if signature.verify
        result
      else
        raise VerficationFailed, "Signature verification failed: #{signature.signature} != #{signature.request.signature}"
      end
    end
  end
end
