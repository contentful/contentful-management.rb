# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'contentful/management/version'

Gem::Specification.new do |spec|
  spec.name          = 'contentful-management'
  spec.version       = Contentful::Management::VERSION
  spec.authors       = ['Contentful GmbH (Andreas Tiefenthaler)']
  spec.email         = ['rubygems@contentful.com']
  spec.summary       = %q{contentful management api}
  spec.description   = %q{Ruby client for the https://www.contentful.com Content Management API}
  spec.homepage      = 'https://github.com/contentful/contentful-management.rb'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'http', '~> 0.6'
  spec.add_dependency 'multi_json', '~> 1'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'

  spec.add_development_dependency 'rspec', '~> 3'
  spec.add_development_dependency 'rspec-its'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'vcr'
  spec.add_development_dependency 'webmock', '~> 1', '>= 1.17.3'
end
