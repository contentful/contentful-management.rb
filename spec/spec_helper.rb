require 'simplecov'
SimpleCov.start

require 'rspec'
require 'contentful/management'
require 'pry'
require 'rspec/its'

Dir[File.dirname(__FILE__) + '/support/**/*.rb'].each { |f| require f }

RSpec.configure do |config|
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
end
