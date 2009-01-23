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

    def ==(user_access)
      return false unless user_access.is_a?(UserAccess)
      [consumer, request_shared_key, token] == [user_access.consumer, user_access.request_shared_key, user_access.token]
    end
  end
end
