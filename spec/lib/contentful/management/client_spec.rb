require 'spec_helper'

require 'contentful/management/client'

module Contentful
  module Management
    describe Client do
      let(:token) { 'such_a_long_token' }
      # let(:token) { '005d6f51203bcae1fa9b44d92d810f2ca32337c3559857eacfedc65cee4d7a3c' }

      let(:client) { Client.new(token) }

      subject { client }

      its(:access_token) { should be token }

      describe 'headers' do
        describe '#authentication_header' do
          its(:authentication_header) { should be_kind_of Hash }
          its(:authentication_header) { should eql 'Authorization' => 'Bearer such_a_long_token' }
        end

        describe '#api_header' do
          its(:api_header) { should be_kind_of Hash }
          its(:api_header) { should eql 'Content-Type' => 'application/vnd.contentful.management.v1+json' }
        end

        describe '#request_headers' do
          its(:request_headers) { should be_kind_of Hash }
          its(:request_headers) { should include client.authentication_header }
          its(:request_headers) { should include client.api_header }
          its(:request_headers) { should include client.user_agent }
        end

        describe '#user_agent' do
          its(:user_agent) { should be_kind_of Hash }
          its(:user_agent) { should eq 'User-Agent' => "RubyContenfulManagementGem/#{Contentful::Management::VERSION}" }
        end

        describe '#organization_header' do
          it 'is a hash' do
            expect(client.organization_header('MyOrganizationID')).to be_kind_of Hash
          end

          it 'returns the "X-Contentful-Organization" header' do
            expect(client.organization_header('MyOrganizationID'))
              .to eql 'X-Contentful-Organization' => 'MyOrganizationID'
          end
        end
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

      describe '.post_http' do
        it 'does a GET request'
      end

      describe '.get_http' do
        subject { Client }
        it 'does a GET request' do
          vcr(:get_request) { subject.get_http('http://example.com', foo: 'bar') }
        end
      end
    end
  end
end
