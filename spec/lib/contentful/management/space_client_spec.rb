require 'spec_helper'

require 'contentful/management/client'

module Contentful
  module Management
    describe SpaceClient do
      let(:token) { 'such_a_long_token' }
      let(:client) { Client.new(token) }
      let(:space_id) { 'xxddi16swo35' }
      subject { client }

      describe '#spaces' do
        it 'returns a Contentful::Array' do
          vcr(:get_spaces) { expect(client.spaces).to be_kind_of Contentful::Array }
        end

        it 'builds a Contentful::Space object' do
          vcr(:get_spaces) { expect(client.spaces.first).to be_kind_of Contentful::Space }
        end
      end

      describe '#space' do
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

      describe '#update_space' do
        let(:space_version) { 1 }

        it 'updates the space name' do
          vcr(:update_space) do
            updated_space = client.update_space(space_id, 'NewName', space_version)
            expect(updated_space.sys[:version]).to eql space_version + 1
          end
        end

        it 'returns an error when the wrong version is supplied' do
          vcr(:update_space_with_wrong_version) do
            updated_space = client.update_space(space_id, 'NewName', space_version)
            expect(updated_space).to be_kind_of Contentful::Error
          end
        end
      end
    end
  end
end
