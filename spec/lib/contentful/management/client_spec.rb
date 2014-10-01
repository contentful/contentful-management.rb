require 'spec_helper'
require 'contentful/management/client'

module Contentful
  module Management
    describe Client do
      let(:token) { '<ACCESS_TOKEN>' }
      let(:client) { Client.new(token) }

      subject { client }

      its(:access_token) { should be token }

      describe 'headers' do
        describe '#authentication_header' do
          its(:authentication_header) { should be_kind_of Hash }
          its(:authentication_header) { should eql 'Authorization' => 'Bearer <ACCESS_TOKEN>' }
        end

        describe '#api_version_header' do
          its(:api_version_header) { should be_kind_of Hash }
          its(:api_version_header) { should eql 'Content-Type' => 'application/vnd.contentful.management.v1+json' }
        end

        describe '#request_headers' do
          its(:request_headers) { should be_kind_of Hash }
          its(:request_headers) { should include client.authentication_header }
          its(:request_headers) { should include client.api_version_header }
          its(:request_headers) { should include client.user_agent }
        end

        describe '#user_agent' do
          its(:user_agent) { should be_kind_of Hash }
          its(:user_agent) { should eq 'User-Agent' => "RubyContenfulManagementGem/#{ Contentful::Management::VERSION }" }
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

      describe '#default_locale' do
        it 'is http when secure set to true' do
          client = Client.new('token', secure: true)
          expect(client.default_locale).to eql 'en-US'
        end
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
