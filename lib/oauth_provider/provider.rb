module OAuthProvider
  class Provider
    class VerficationFailed < StandardError; end

    def initialize(backend_type, *args)
      @backend = Backends.for(backend_type, *args)
    end
    attr_reader :backend

    def add_consumer(name, callback)
      Consumer.create(self, name, callback)
    end

    def consumer_for(shared_key)
      if data = @backend.fetch_consumer(shared_key)
        return Consumer.new(self, *data)
      end
      raise "Consumer not found with shared key: #{shared_key.inspect}"
    end

    def issue_token(request)
      consumer = verify(request, :consumer)
      consumer.issue_token
    end

    def request_token_for(consumer_shared_key, shared_key)
      if data = @backend.fetch_request_token(consumer_shared_key, shared_key)
        consumer = consumer_for(consumer_shared_key)
        return Token.new(consumer, *data)
      end
      raise "Request token not found for consumer #{consumer_shared_key.inspect} with shared key #{shared_key.inspect}"
    end

    def upgrade_token(request)
      token = verify(request, :request)
      token.upgrade
    end

    def access_token_for(consumer_shared_key, shared_key)
      if data = @backend.fetch_access_token(consumer_shared_key, shared_key)
        consumer = consumer_for(consumer_shared_key)
        return Token.new(consumer, *data)
      end
      raise NoAccessToken, "Access token not found for consumer #{consumer_shared_key.inspect} with shared key #{shared_key.inspect}"
    end

    def validate_token(request)
      verify(request, :access)
    end

    include OAuth::Helper
    def generate_shared_key
      generate_key(16)
    end

    def generate_secret_key
      generate_key
    end

    private

    def verify(request, type, &block)
      token, consumer = nil, nil

      signature = OAuth::Signature.build(request) do |shared_key,consumer_shared_key|
        consumer = consumer_for(consumer_shared_key)
        case type
        when :request
          token = request_token_for(consumer_shared_key, shared_key)
        when :access
          token = access_token_for(consumer_shared_key, shared_key)
        when :consumer
        else
          raise ArgumentError, "Type should be one of :request, :access or :consumer"
        end
        [token && token.secret_key, consumer.secret_key]
      end

      if signature.verify
        type == :consumer ? consumer : token
      else
        warn "Signature verify fail: Base: #{signature.signature_base_string}. Signature: #{signature.signature}"
        raise VerficationFailed, "Signature verification failed"
      end
    end
  end
end
