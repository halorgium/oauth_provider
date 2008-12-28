module OAuthProvider
  class RequestToken
    def initialize(consumer, authorized, shared, secret)
      @consumer, @authorized, @shared, @secret = consumer, authorized, shared, secret
    end
    attr_reader :authorized

    def authorize
      consumer.authorize_request_token(self)
      @authorized = true
    end

    def upgrade
      shared, secret = Provider.generate_credentials
      AccessToken.new(@consumer, shared, shared, secret)
    end

    def callback
      @consumer.callback
    end

    include TokenMethods
  end
end
