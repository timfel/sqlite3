$:.unshift File.expand_path("../lib", __FILE__)

require "rubygems"
require "rubygems/specification"
require "rspec/core/rake_task"
require "rake/gempackagetask"
require "sqlite3"

def gemspec
  file = File.expand_path('../sqlite3.gemspec', __FILE__)
  eval(File.read(file), binding, file)
end

RSpec::Core::RakeTask.new do |t|
end

Rake::GemPackageTask.new(gemspec) do |pkg|
  pkg.gem_spec = gemspec
end

desc "Install the gem locally"
task :install => :package do
  sh %{gem install pkg/#{gemspec.name}-#{gemspec.version}}
end

desc "Validate the gemspec"
task :gemspec do
  gemspec.validate
end

task :gem => :gemspec
task :default => :test
