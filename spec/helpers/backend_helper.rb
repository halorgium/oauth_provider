module OAuthBackendHelper
  module InMemory
    def self.setup; end
    def self.reset; end
  end

  module DataMapper
    def self.setup
      require 'dm-core'
      ::DataMapper.setup(:default, "sqlite3:///tmp/oauth_provider_test.sqlite3")
    end

    def self.reset
      OAuthProvider.create(:data_mapper)
      ::DataMapper.auto_migrate!
    end
  end

  def self.setup
    backend_module.setup
  end

  def self.reset
    backend_module.reset
  end

  def self.provider
    OAuthProvider.create(backend_name)
  end

  def self.backend_module
    klass_name = backend_name.to_s.split('_').map {|e| e.capitalize}.join
    unless const_defined?(klass_name)
      $stderr.puts "There is no backend for #{backend_name.inspect}"
      exit!
    end
    const_get(klass_name)
  end

  def self.backend_name
    (ENV["BACKEND"] || "in_memory").to_sym
  end
end
