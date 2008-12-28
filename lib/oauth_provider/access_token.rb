module OAuthProvider
  class AccessToken
    def initialize(consumer, request_shared, shared, secret)
      @consumer, @request_shared, @shared, @secret = consumer, request_shared, shared, secret
    end
    attr_reader :request_shared

    include TokenMethods
  end
end
