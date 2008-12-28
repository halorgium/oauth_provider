module OAuthProvider
  module TokenMethods
    attr_reader :shared, :secret, :consumer

    def query_string
      OAuth::Token.new(shared, secret).to_query
    end

    def consumer_shared
      @consumer.shared
    end
  end
end
