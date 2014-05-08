require 'bundler/gem_tasks'
require 'rubygems'
require 'rake'

begin
  require 'bundler'
rescue LoadError => e
  warn e.message
  warn 'Run `gem install bundler` to install Bundler.'
  exit 1
end

begin
  Bundler.setup(:development)
rescue Bundler::BundlerError => e
  warn e.message
  warn 'Run `bundle install` to install missing gems.'
  exit e.status_code
end


require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

task :test    => :spec
task :default => :spec

require 'rubocop/rake_task'

Rubocop::RakeTask.new

require 'reek/rake/task'

Reek::Rake::Task.new do |t|
  t.fail_on_error = false
end


desc 'Run specs, rubocop and reek'
task ci: %w[spec reek rubocop]
