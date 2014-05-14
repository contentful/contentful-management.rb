require 'simplecov'
SimpleCov.start

require 'rspec'
require 'contentful/management'
require 'pry'

Dir[File.dirname(__FILE__) + '/support/**/*.rb'].each { |f| require f }
