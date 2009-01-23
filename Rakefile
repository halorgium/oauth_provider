require 'rake/gempackagetask'

require 'thor'

require File.dirname(__FILE__) + '/lib/oauth_provider/version'
require File.dirname(__FILE__) + '/tasks/merb.thor/ops'

GEM_NAME = "oauth_provider"
AUTHOR = "halorgium"
EMAIL = "tim@spork.in"
HOMEPAGE = "http://github.com/halorgium/oauth_provider/tree/master"
SUMMARY = "Oauth provider wrapper"
GEM_VERSION = OAuthProvider::VERSION

spec = Gem::Specification.new do |s|
  s.rubyforge_project = 'oauth_provider'
  s.name = GEM_NAME
  s.version = GEM_VERSION
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = []
  s.summary = SUMMARY
  s.description = s.summary
  s.authors = AUTHOR
  s.email = EMAIL
  s.homepage = HOMEPAGE

  deps = Thor::Tasks::Merb::Collector.collect(File.read('config/dependencies.rb'))
  deps.each do |dep|
    name, version = dep.first, dep.last
    if version
      s.add_dependency(name, version)
    else
      s.add_dependency(name)
    end
  end
  s.require_path = 'lib'
  s.files = %w(Rakefile) + Dir.glob("{lib,config,spec}/**/*")
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "Install the gem"
task :install do
  Merb::RakeHelper.install(GEM_NAME, :version => GEM_VERSION)
end

desc "Uninstall the gem"
task :uninstall do
  Merb::RakeHelper.uninstall(GEM_NAME, :version => GEM_VERSION)
end

desc "Create a gemspec file"
task :gemspec do
  File.open("#{GEM_NAME}.gemspec", "w") do |file|
    file.puts spec.to_ruby
  end
end

require 'spec/rake/spectask'

base_dir = File.expand_path(File.dirname(__FILE__))
desc 'Default: run spec examples'
Spec::Rake::SpecTask.new(:default) do |t|
  t.spec_opts << %w(-fs --color)
  t.spec_opts << '--loadby' << 'random'
  t.spec_files = Dir["#{base_dir}/spec/**/*_spec.rb"]
  t.rcov = false
  t.rcov_opts << '--exclude' << 'spec,config,gems'
  t.rcov_opts << '--text-summary'
  t.rcov_opts << '--sort' << 'coverage' << '--sort-reverse'
end

desc "Release the version"
task :release => :package do
  version = OAuthProvider::VERSION
  puts "Releasing #{version}"

  `git show-ref tags/v#{version}`
  unless $?.success?
    abort "There is no tag for v#{version}"
  end

  `git show-ref heads/releasing`
  if $?.success?
    abort "Remove the releasing branch, we need it!"
  end

  puts "Checking out to the releasing branch as the tag"
  system("git", "checkout", "-b", "releasing", "tags/v#{version}")

  puts "Reseting back to master"
  system("git", "checkout", "master")
  system("git", "branch", "-d", "releasing")

  ints = Gem::Version.new(version).ints << 0
  next_version = Gem::Version.new(ints.join(".")).bump

  puts "Changing the version to #{next_version}."

  version_file = "#{File.dirname(__FILE__)}/lib/#{GEM_NAME}/version.rb"
  File.open(version_file, "w") do |f|
    f.puts <<-EOT
module OAuthProvider
  VERSION = "#{next_version}"
end
    EOT
  end

  puts "Committing the version change"
  system("git", "commit", version_file, "-m", "Next version: #{next_version}")

  puts "Push the commit up! if you don't, you'll be hunted down"
end
