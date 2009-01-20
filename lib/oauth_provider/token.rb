module OAuthProvider
  class Token
    def self.generate
      new(generate_key(16), generate_key)
    end

    def self.generate_key(size = 32)
      Base64.encode64(OpenSSL::Random.random_bytes(size)).gsub(/\W/,'')
    end

    def initialize(shared_key, secret_key)
      @shared_key, @secret_key = shared_key, secret_key
    end
    attr_reader :shared_key, :secret_key

    def query_string
      OAuth::Token.new(shared_key, secret_key).to_query
    end

    def ==(token)
      return false unless token.is_a?(Token)
      [shared_key, secret_key].eql?([token.shared_key, token.secret_key])
    end
  end
end
