module OAuthProvider
  class UserAccess
    def initialize(consumer, token)
      @consumer, @token = consumer, token
    end
    attr_reader :consumer, :token

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
