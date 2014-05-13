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

      describe '#protocol' do
        its(:protocol) { should eql 'https' }

        it 'is http when secure set to true' do
          client = Client.new('token', secure: true)
          expect(client.protocol).to eql 'https'
        end

        it 'is http when secure set to false' do
          client = Client.new('token', secure: false)
          expect(client.protocol).to eql 'http'
        end
      end

      describe '#spaces' do
        it 'returns a Contentful::Array' do
          vcr(:get_spaces) { expect(client.spaces).to be_kind_of Contentful::Array }
        end

        it 'builds a Contentful::Space object' do
          vcr(:get_spaces) { expect(client.spaces.first).to be_kind_of Contentful::Space }
        end
      end

      describe '#space' do
        let(:space_id) { 'xxddi16swo35' }
        it 'returns a Contentful::Space' do
          vcr(:get_space) { expect(client.space(space_id)).to be_kind_of Contentful::Space }
        end

        it 'returns the space for a given key' do
          vcr(:get_space) do
            space = client.space(space_id)
            expect(space.id).to eql space_id
          end
        end
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
