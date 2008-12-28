module OAuthProvider
  class Consumer
    def initialize(store, name, shared, secret, callback)
      @store, @name, @shared, @secret, @callback = store, name, shared, secret, callback
    end
    attr_reader :name, :shared, :secret, :callback

    def generate_request_token
      shared, secret = Provider.generate_credentials
      RequestToken.new(self, false, shared, secret)
    end

    def authorize_request_token(token)
      @store.authorize_request_token(token)
    end
  end
end
