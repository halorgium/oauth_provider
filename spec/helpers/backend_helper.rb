require 'fileutils'

module OAuthBackendHelper
  module InMemory
    def self.create
      OAuthProvider.create(:in_memory)
    end

    def self.setup; end
    def self.reset; end
  end

  module DataMapper
    def self.create
      OAuthProvider.create(:data_mapper)
    end

    def self.setup
      require 'dm-core'
      ::DataMapper.setup(:default, "sqlite3:///tmp/oauth_provider_test.sqlite3")
    end

    def self.reset
      create
      ::DataMapper.auto_migrate!
    end
  end

  module Sqlite3
    PATH = "/tmp/oauth_provider_sqlite3_test.sqlite3"

    def self.create
      OAuthProvider.create(:sqlite3, PATH)
    end

    def self.setup; end

    def self.reset
      FileUtils.rm(PATH) rescue nil
    end
  end

  def self.setup
    backend_module.setup
  end

  def self.reset
    backend_module.reset
  end

  def self.provider
    backend_module.create
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
