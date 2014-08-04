# -*- encoding: utf-8 -*-
require 'simplecov'
SimpleCov.start

require 'rspec'
require 'contentful/management'
require 'pry'
require 'rspec/its'

Dir[File.dirname(__FILE__) + '/support/**/*.rb'].each { |f| require f }
