lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'contentful/management/version'

Gem::Specification.new do |spec|
  spec.name          = 'contentful-management'
  spec.version       = Contentful::Management::VERSION
  spec.authors       = ['Piotr Protas','Tomasz Warkocki','Contentful GmbH (Andreas Tiefenthaler)']
  spec.email         = ['piotrek@codequest.com','warkocz@gmail.com', 'rubygems@contentful.com']
  spec.summary       = %q{contentful management api}
  spec.description   = %q{Ruby client for the https://www.contentful.com Content Management API}
  spec.homepage      = 'https://github.com/contentful/contentful-management.rb'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'http', '> 1.0', '< 3.0'
  spec.add_dependency 'multi_json', '~> 1'
  spec.add_dependency 'json', '~> 1.8'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake', '< 11.0'
  spec.add_development_dependency 'public_suffix', '< 1.5'
  spec.add_development_dependency 'rspec', '~> 3'
  spec.add_development_dependency 'rspec-its'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'guard-rubocop'
  spec.add_development_dependency 'guard-yard'
  spec.add_development_dependency 'rubocop', '~> 0.49.1'
  spec.add_development_dependency 'listen', '~> 3.0'
  spec.add_development_dependency 'vcr'
  spec.add_development_dependency 'webmock', '~> 1', '>= 1.17.3'
  spec.add_development_dependency 'simplecov'
end
