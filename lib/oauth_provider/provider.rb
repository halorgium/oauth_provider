module OAuthProvider
  class Provider
    def initialize(store)
      @store = store
    end

    def consumer_for(shared)
      @store.fetch_consumer(shared)
    end

    def add_consumer(name, shared, secret, callback)
      consumer = Consumer.new(self, name, shared, secret, callback)
      @store.save_consumer(consumer)
      consumer
    end

    def generate_request_token(request)
      consumer = verify(request, :consumer)
      request_token = consumer.generate_request_token
      @store.save_request_token(request_token)
      request_token
    end

    def request_token_for(shared)
      @store.fetch_request_token(shared, nil)
    end

    def generate_access_token(request)
      request_token = verify(request, :request)
      access_token = request_token.upgrade
      @store.save_access_token(access_token)
      access_token
    end

    def check_access(request)
      verify(request, :access)
    end

    def self.generate_credentials
      OAuth::Server.new(nil).generate_credentials
    end

    private

    def verify(request, type, &block)
      token, consumer = nil, nil

      signature = OAuth::Signature.build(request) do |shared,consumer_shared|
        consumer = @store.fetch_consumer(consumer_shared) || raise("Consumer not found")
        case type
        when :request
          token = @store.fetch_request_token(shared, consumer_shared) || raise("Request token not found")
        when :access
          token = @store.fetch_access_token(shared, consumer_shared) || raise("Access token not found")
        when :consumer
        else
          raise ArgumentError, "Type should be one of :request, :access or :consumer"
        end
        [token && token.secret, consumer.secret]
      end

      if signature.verify
        type == :consumer ? consumer : token
      else
        warn "Signature verify fail: Base: #{signature.signature_base_string}. Signature: #{signature.signature}"
        throw :halt, [401, "Signature verification failed"]
      end
    end
  end
end
