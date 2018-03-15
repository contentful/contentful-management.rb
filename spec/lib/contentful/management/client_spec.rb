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
          its(:user_agent) { should eq 'X-Contentful-User-Agent' => client.contentful_user_agent }
        end

        describe 'X-Contentful-User-Agent header' do
          it 'default values' do
            expected = [
              "sdk contentful-management.rb/#{Contentful::Management::VERSION};",
              "platform ruby/#{RUBY_VERSION};"
            ]

            client = Client.new(token)
            expected.each do |h|
              expect(client.contentful_user_agent).to include(h)
            end

            expect(client.contentful_user_agent).to match(/os (Windows|macOS|Linux)(\/.*)?;/i)

            ['integration', 'app'].each do |h|
              expect(client.contentful_user_agent).not_to include(h)
            end
          end

          it 'with integration name only' do
            expected = [
              "sdk contentful-management.rb/#{Contentful::Management::VERSION};",
              "platform ruby/#{RUBY_VERSION};",
              "integration foobar;"
            ]

            client = Client.new(
              token,
              integration_name: 'foobar'
            )
            expected.each do |h|
              expect(client.contentful_user_agent).to include(h)
            end

            expect(client.contentful_user_agent).to match(/os (Windows|macOS|Linux)(\/.*)?;/i)

            ['app'].each do |h|
              expect(client.contentful_user_agent).not_to include(h)
            end
          end

          it 'with integration' do
            expected = [
              "sdk contentful-management.rb/#{Contentful::Management::VERSION};",
              "platform ruby/#{RUBY_VERSION};",
              "integration foobar/0.1.0;"
            ]

            client = Client.new(
              token,
              integration_name: 'foobar',
              integration_version: '0.1.0'
            )
            expected.each do |h|
              expect(client.contentful_user_agent).to include(h)
            end

            expect(client.contentful_user_agent).to match(/os (Windows|macOS|Linux)(\/.*)?;/i)

            ['app'].each do |h|
              expect(client.contentful_user_agent).not_to include(h)
            end
          end

          it 'with application name only' do
            expected = [
              "sdk contentful-management.rb/#{Contentful::Management::VERSION};",
              "platform ruby/#{RUBY_VERSION};",
              "app fooapp;"
            ]

            client = Client.new(
              token,
              application_name: 'fooapp'
            )
            expected.each do |h|
              expect(client.contentful_user_agent).to include(h)
            end

            expect(client.contentful_user_agent).to match(/os (Windows|macOS|Linux)(\/.*)?;/i)

            ['integration'].each do |h|
              expect(client.contentful_user_agent).not_to include(h)
            end
          end

          it 'with application' do
            expected = [
              "sdk contentful-management.rb/#{Contentful::Management::VERSION};",
              "platform ruby/#{RUBY_VERSION};",
              "app fooapp/1.0.0;"
            ]

            client = Client.new(
              token,
              application_name: 'fooapp',
              application_version: '1.0.0'
            )
            expected.each do |h|
              expect(client.contentful_user_agent).to include(h)
            end

            expect(client.contentful_user_agent).to match(/os (Windows|macOS|Linux)(\/.*)?;/i)

            ['integration'].each do |h|
              expect(client.contentful_user_agent).not_to include(h)
            end
          end

          it 'with all' do
            expected = [
              "sdk contentful-management.rb/#{Contentful::Management::VERSION};",
              "platform ruby/#{RUBY_VERSION};",
              "integration foobar/0.1.0;",
                "app fooapp/1.0.0;"
            ]

            client = Client.new(
              token,
              integration_name: 'foobar',
              integration_version: '0.1.0',
              application_name: 'fooapp',
              application_version: '1.0.0'
            )

            expected.each do |h|
              expect(client.contentful_user_agent).to include(h)
            end

            expect(client.contentful_user_agent).to match(/os (Windows|macOS|Linux)(\/.*)?;/i)
          end

          it 'when only version numbers, skips header' do
            expected = [
              "sdk contentful-management.rb/#{Contentful::Management::VERSION};",
              "platform ruby/#{RUBY_VERSION};"
            ]

            client = Client.new(
              token,
              integration_version: '0.1.0',
              application_version: '1.0.0'
            )

            expected.each do |h|
              expect(client.contentful_user_agent).to include(h)
            end

            expect(client.contentful_user_agent).to match(/os (Windows|macOS|Linux)(\/.*)?;/i)

            ['integration', 'app'].each do |h|
              expect(client.contentful_user_agent).not_to include(h)
            end
          end

          it 'headers include X-Contentful-User-Agent' do
            client = Client.new(token)
            expect(client.request_headers['X-Contentful-User-Agent']).to eq client.contentful_user_agent
          end
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

      describe '#host_url' do
        describe 'uploads' do
          it 'returns uploads url when its a properly formed upload url' do
            expect(subject.host_url(RequestDouble.new('spaces/some_space_id/uploads'))).to eq subject.uploads_url
            expect(subject.host_url(RequestDouble.new('spaces/some_space_id/uploads/upload_id'))).to eq subject.uploads_url
            expect(subject.host_url(RequestDouble.new('spaces/uploads/uploads/uploads'))).to eq subject.uploads_url
          end

          it 'returns base url for non uploads url' do
            uploads_as_space_id = 'spaces/uploads/entries/upload_id'
            expect(subject.host_url(RequestDouble.new(uploads_as_space_id))).to eq subject.base_url

            uploads_as_entry_id = 'spaces/some_space_id/entries/uploads'
            expect(subject.host_url(RequestDouble.new(uploads_as_entry_id))).to eq subject.base_url

            uploads_as_only_thing = 'spaces/uploads'
            expect(subject.host_url(RequestDouble.new(uploads_as_only_thing))).to eq subject.base_url
          end
        end

        it 'returns base url otherwise' do
          expect(subject.host_url(RequestDouble.new('/some_space_id'))).to eq subject.base_url
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

      describe 'http methods' do
        let(:request) { Request.new(client, 'http://example.com', foo: 'bar') }
        describe '#get' do
          it 'does a GET request' do
            vcr(:get_request) { subject.get(Request.new(client, 'http://mockbin.org/bin/be499b1d-286a-4d22-8d26-00a014b83817', foo: 'bar')) }
          end
        end

        describe '#post' do
          it 'does a POST request' do
            vcr(:post_request) { subject.post(request) }
          end
        end

        describe '#put' do
          it 'does a PUT request' do
            vcr(:put_request) { subject.put(request) }
          end
        end

        describe '#delete' do
          it 'does a DELETE request' do
            vcr(:delete_request) { subject.delete(request) }
          end
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
            expect(subject).to receive(:proxy_send).once.and_call_original
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
