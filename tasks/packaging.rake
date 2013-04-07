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

  current = version.to_s + ".0"
  next_version = Gem::Version.new(current).bump

  puts "Changing the version to #{next_version}."

  version_file = "#{File.dirname(__FILE__)}/../lib/#{GEM_NAME}/version.rb"
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
