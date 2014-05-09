require 'spec_helper'

require 'contentful/management/client'

module Contentful
  module Management
    describe Client do
      let(:token) { 'such_a_long_token' }
      let(:client) { Client.new(token) }
      subject { client }

      its(:access_token) { should be token }

      describe '#authentication_header' do
        its(:authentication_header) { should be_kind_of Hash }
        its(:authentication_header) { should eql 'Authorization' => 'Bearer such_a_long_token' }
      end

      describe '#api_header' do
        its(:api_header) { should be_kind_of Hash }
        its(:api_header) { should eql 'Content-Type' => 'application/vnd.contentful.delivery.v1+json' }
      end

      describe '#request_headers' do
        its(:request_headers) { should be_kind_of Hash }
        its(:request_headers) { should include client.authentication_header }
        its(:request_headers) { should include client.api_header }
        its(:request_headers) { should include client.user_agent }
      end

      describe '#user_agent' do
        its(:user_agent) { should be_kind_of Hash }
        its(:user_agent) { should eql 'User-Agent' => "RubyContenfulManagementGem/#{Contentful::Management::VERSION}" }
      end

      describe '.get_http' do
        subject { Client }
        it 'does a get_request' do
          vcr(:get_request) { subject.get_http('http://example.com', foo: 'bar') }
        end
      end
    end
  end
end
