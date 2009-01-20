module OAuthProvider
  class UserRequest
    def initialize(backend, consumer, authorized, token)
      @backend, @consumer, @authorized, @token = backend, consumer, authorized, token
    end
    attr_reader :consumer, :token

    def authorized?
      @authorized
    end

    def authorize
      @authorized = true
      @backend.save_user_request(self)
    end

    def upgrade
      if authorized?
        @backend.add_user_access(self)
      else
        raise UserRequestNotAuthorized.new(self)
      end
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
