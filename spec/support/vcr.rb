require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.ignore_localhost = true
  c.hook_into :webmock
  c.default_cassette_options = {record: :once}
  c.filter_sensitive_data('<ACCESS_TOKEN>') { '51cb89f45412ada2be4361599a96d6245e19913b6d2575eaf89dafaf99a443aa' }
end

def vcr(name, &block)
  VCR.use_cassette(name, &block)
end

def expect_vcr(name, &block)
  expect { VCR.use_cassette(name, &block) }
end
