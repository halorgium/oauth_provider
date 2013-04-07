require File.dirname(__FILE__) + '/lib/oauth_provider/version'

Gem::Specification.new do |s|
  s.rubyforge_project = 'oauth_provider'
  s.name = "oauth_provider"
  s.version = OAuthProvider::VERSION
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = []
  s.summary = "Oauth provider wrapper"
  s.description = s.summary
  s.authors = "halorgium"
  s.email = "tim@spork.in"
  s.homepage = "http://github.com/halorgium/oauth_provider/tree/master"

  s.add_dependency("oauth")
  s.require_path = 'lib'
  s.files = Dir.glob("lib/**/*.rb")
end
