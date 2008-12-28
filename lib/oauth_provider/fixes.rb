# Extend OAuth::Token to be able to create the correct query string form
module OAuth
  class Token
    def to_query
      "oauth_token=#{escape(token)}&oauth_token_secret=#{escape(secret)}"
    end
  end
end
