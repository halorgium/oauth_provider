module OAuthProvider
  class Consumer
    def self.create(provider, name, callback)
      new(provider, name, callback).save
    end

    def initialize(provider, name, callback, shared_key = nil, secret_key = nil)
      @provider, @name, @callback = provider, name, callback
      @shared_key, @secret_key = shared_key || @provider.generate_shared_key, secret_key || @provider.generate_secret_key
    end
    attr_reader :provider, :name, :callback, :shared_key, :secret_key

    def issue_token
      Token.create(self)
    end

    #def authorize_request_token(token)
      #@provider.authorize_request_token(token)
    #end

    def save
      backend.create_consumer(name, callback, shared_key, secret_key)
      self
    end

    private
      def backend
        @provider.backend
      end
  end
end
