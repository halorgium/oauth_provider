module OAuthProvider
  class Consumer
    def initialize(provider, callback, token)
      @provider, @callback, @token = provider, callback, token
    end
    attr_reader :provider, :callback, :token

    def issue_request
      @provider.add_user_access(self)
    end

    def shared_key
      @token.shared_key
    end

    def secret_key
      @token.secret_key
    end
  end
end
