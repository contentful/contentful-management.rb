require 'simplecov'
SimpleCov.start unless RUBY_PLATFORM == 'java'

require 'rspec'
require 'contentful/management'
require 'pry'
require 'rspec/its'

Dir[File.dirname(__FILE__) + '/support/**/*.rb'].each { |f| require f }

RSpec.configure do |config|
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
end

class RequestDouble
  attr_reader :url

  def initialize(url)
    @url = url
  end
end
