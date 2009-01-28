require File.dirname(__FILE__) + '/lib/oauth_provider/version'

task :packaging do
  load File.dirname(__FILE__) + '/tasks/packaging.rake'
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

task :integration do
  %w( in_memory data_mapper sqlite3 mysql ).each do |backend|
    ENV["BACKEND"] = backend
    puts "Running specs with #{backend} backend..."
    system("spec", "-O", "spec/spec.opts", "spec")
  end
end
