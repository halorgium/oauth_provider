module OAuthProvider
  module Backends
    def self.for(type, *args)
      require "oauth_provider/backends/#{type}"
      klass_name = type.to_s.split('_').map {|e| e.capitalize}.join
      const_get(klass_name).new(*args)
    end
  end
end
