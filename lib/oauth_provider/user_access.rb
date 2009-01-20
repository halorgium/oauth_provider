module OAuthProvider
  class UserAccess
    def initialize(backend, consumer, request_shared_key, token)
      @backend, @consumer, @request_shared_key, @token = backend, consumer, request_shared_key, token
    end
    attr_reader :consumer, :request_shared_key, :token

    def query_string
      @token.query_string
    end

    def shared_key
      @token.shared_key
    end

    def secret_key
      @token.secret_key
    end
  end
end
