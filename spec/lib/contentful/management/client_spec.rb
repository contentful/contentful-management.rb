require 'spec_helper'

require 'contentful/management/client'

module Contentful
  module Management
    describe Client do
      let(:token) { 'such_a_long_token' }

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

      describe '#delete_space' do
        let(:space_id) { 'ke4xbiyjucra' }
        it 'returns true when a space was deleted' do
          vcr(:delete_space_success) do
            result = client.delete_space(space_id)

            expect(result).to eql true
          end
        end

        it 'returns an error when something went wrong' do
          vcr(:delete_space_not_found) do
            result = client.delete_space('no_space_here')
            expect(result).to be_kind_of Contentful::NotFound
          end
        end
      end

      describe '#create_space' do
        let(:space_name) { 'My Space' }
        let(:organization_id)  { '2w3epLcMkfb2RPVCLrNSwV' }

        it 'creates a space within an organization' do
          vcr(:create_space) do
            space = client.create_space(space_name, organization_id)
            expect(space).to be_kind_of Contentful::Space
            expect(space.name).to eq space_name
          end
        end

        it 'creates a space when the user only has one organization' do
          vcr(:create_space_without_organization) do
            space = client.create_space(space_name)
            expect(space).to be_kind_of Contentful::Space
            expect(space.name).to eq space_name
          end
        end

        it 'returns an error when the organization needs to passed' do
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
