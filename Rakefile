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

require 'rubocop/rake_task'
RuboCop::RakeTask.new

desc 'Run specs, rubocop and reek'
task ci: %w(spec reek rubocop)

task rspec_rubocop: %w(spec rubocop)

task test: :spec
task default: :spec
