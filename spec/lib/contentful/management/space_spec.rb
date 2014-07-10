require 'spec_helper'
require 'contentful/management/space'
require 'contentful/management/client'

module Contentful
  module Management
    describe Space do
      let(:token) { '51cb89f45412ada2be4361599a96d6245e19913b6d2575eaf89dafaf99a443aa' }
      let(:space_id) { 'n6spjc167pc2' }

      let!(:client) { Client.new(token) }

      subject { Contentful::Management::Space }

      describe '.all' do
        it 'returns a Contentful::Array' do
          vcr(:get_spaces) { expect(subject.all).to be_kind_of Contentful::Array }
        end

        it 'builds a Contentful::Space object' do
          vcr(:get_spaces) { expect(subject.all.first).to be_kind_of Contentful::Management::Space }
        end
      end

      describe '#space' do
        it 'returns a Contentful::Space' do
          vcr(:get_space) { expect(subject.find(space_id)).to be_kind_of Contentful::Management::Space }
        end

        it 'returns the space for a given key' do
          vcr(:get_space) do
            space = subject.find(space_id)
            expect(space.id).to eql space_id
          end
        end
      end

      describe '#destroy' do

        it 'returns true when a space was deleted' do
          vcr(:delete_space_success) do
            result = subject.find('3gpluolpxxzb').destroy
            expect(result).to eql true
          end
        end

        it 'returns an error when something went wrong' do
          vcr(:delete_space_not_found) do
            result = subject.find('not_exist')
            expect(result).to be_kind_of Contentful::NotFound
          end
        end
      end

      describe '.create' do
        let(:space_name) { 'My Test Space' }
        let(:organization_id) { '2w3epLcMkfb2RPVCLrNSwV' }

        it 'creates a space within an organization' do
          vcr(:create_space) do
            space = subject.create({name: space_name, organization: organization_id})
            expect(space).to be_kind_of Contentful::Management::Space
            expect(space.name).to eq space_name
          end
        end

        it 'creates a space when the user only has one organization' do
          vcr(:create_space_without_organization) do
            space = subject.create({name: space_name})
            expect(space).to be_kind_of Contentful::Management::Space
            expect(space.name).to eq space_name
          end
        end

        it 'creates a space when limit has been reached' do
          vcr(:create_space_when_limit_has_been_reached) do
            space = subject.create({name: space_name})
            expect(space).to be_kind_of Contentful::AccessDenied
          end
        end
      end

      describe '#update' do
        it 'updates the space name' do
          vcr(:update_space) do
            space = subject.find(space_id)
            initial_version = space.sys[:version]
            space.update(name: "NewNameSpace#{rand(10)}")
            expect(space.sys[:version]).to eql initial_version + 1
          end
        end

        it 'returns an error when the wrong version is supplied' do
          vcr(:update_space_with_wrong_version) do
            updated_space = subject.update(space_id, {name: 'NewName'}, nil, -1)
            expect(updated_space).to be_kind_of Contentful::Error
          end
        end
      end
    end
  end
end