module OAuthProvider
  class UserRequest
    def initialize(consumer, token, user_access)
      @consumer, @token, @user_access = consumer, token, user_access
    end
    attr_reader :consumer, :token, :user_access

    def authorize
      @user_access = @consumer.provider.add_user_access(self)
    end

    def callback
      @consumer.callback
    end

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
