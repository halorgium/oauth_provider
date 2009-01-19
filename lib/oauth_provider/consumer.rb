module OAuthProvider
  class Consumer
    def initialize(provider, name, callback, token)
      @provider, @name, @callback, @token = provider, name, callback, token
    end
    attr_reader :provider, :name, :callback, :token

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
