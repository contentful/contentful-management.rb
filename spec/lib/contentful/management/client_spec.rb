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
          its(:user_agent) { should eq 'User-Agent' => "RubyContentfulManagementGem/#{ Contentful::Management::VERSION }" }
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

      describe '.post_http' do
        subject { Client }
        it 'does a POST request' do
          vcr(:post_request) { subject.post_http('http://example.com', foo: 'bar') }
        end
      end

      describe '.put_http' do
        subject { Client }
        it 'does a PUT request' do
          vcr(:put_request) { subject.put_http('http://example.com', foo: 'bar') }
        end
      end

      describe '.delete_http' do
        subject { Client }
        it 'does a DELETE request' do
          vcr(:delete_request) { subject.delete_http('http://example.com', foo: 'bar') }
        end
      end

      describe 'running with a proxy' do
        subject { Client.new("<ACCESS_TOKEN>", proxy_host: 'localhost', proxy_port: 8888) }
        it 'can run through a proxy' do
          vcr(:proxy_request) {
            space = subject.spaces.find('zh42n1tmsaiq')
            expect(space.name).to eq 'MinecraftVR'
          }
        end

        it 'effectively requests via proxy' do
          vcr(:proxy_request) {
            expect(subject.class).to receive(:proxy_send).twice.and_call_original
            subject.spaces.find('zh42n1tmsaiq')
          }
        end
      end

      describe '.raise_error' do
        it 'raise error set to true' do
          expect(subject.configuration[:raise_errors]).to be_falsey
        end
        it 'raise error set to false' do
          client = Client.new('token', raise_errors: true)
          expect(client.configuration[:raise_errors]).to be_truthy
        end
      end
    end
  end
end
