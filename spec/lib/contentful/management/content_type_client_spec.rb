module Contentful
  module Management
    describe ContentTypeClient do
      let(:token) { 'such_a_long_token' }
      let(:client) { Client.new(token) }
      subject { client }

    end
  end
end
