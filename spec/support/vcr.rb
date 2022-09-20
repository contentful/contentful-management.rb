require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.ignore_localhost = true
  c.hook_into :webmock
  c.default_cassette_options = {record: :once}

  # Redact Contentful Management API tokens from VCR recordings
  c.filter_sensitive_data('<ACCESS_TOKEN>') do |interaction|
    if (auths = interaction.request.headers['Authorization']&.first)
      if (match = auths.match(/^Bearer\s+([^,\s]+)/))
        match.captures.first
      end
    end
  end
end

def vcr(name, &block)
  VCR.use_cassette(name, &block)
end

def expect_vcr(name, &block)
  expect { VCR.use_cassette(name, &block) }
end
