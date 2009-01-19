module OAuthProvider
  class Token
    def self.create(consumer)
      new(consumer).save
    end

    def initialize(consumer, request_shared_key = nil, request_secret_key = nil, access_shared_key = nil, access_secret_key = nil)
      @consumer = consumer
      @request_shared_key, @request_secret_key = request_shared_key || generate_shared_key, request_secret_key || generate_secret_key
      @access_shared_key, @access_secret_key = access_shared_key, access_secret_key
    end
    attr_reader :consumer, :request_shared_key, :request_secret_key, :access_shared_key, :access_secret_key

    def upgrade
      return if authorized?
      @access_shared_key, @access_secret_key = generate_shared_key, generate_secret_key
      save
    end

    def authorized?
      @access_shared_key && @access_secret_key
    end

    def callback
      @consumer.callback
    end

    def query_string
      OAuth::Token.new(shared_key, secret_key).to_query
    end

    def shared_key
      authorized? ? access_shared_key : request_shared_key
    end

    def secret_key
      authorized? ? access_secret_key : request_shared_key
    end

    def provider
      @consumer.provider
    end

    def consumer_shared_key
      @consumer.shared_key
    end

    def save
      if authorized?
        backend.create_access_token(consumer_shared_key, request_shared_key, access_shared_key, access_secret_key)
      else
        backend.create_request_token(consumer_shared_key, request_shared_key, request_secret_key)
      end
      self
    end

    private
      def backend
        provider.backend
      end

      def generate_shared_key
        provider.generate_shared_key
      end

      def generate_secret_key
        provider.generate_secret_key
      end
  end
end
