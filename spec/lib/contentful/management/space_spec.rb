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
        it 'builds a Contentful::Management::Space object' do
          vcr(:get_spaces) { expect(subject.all.first).to be_kind_of Contentful::Management::Space }
        end
      end

      describe '#find' do
        it 'returns a Contentful::Management::Space' do
          vcr(:get_space) { expect(subject.find(space_id)).to be_kind_of Contentful::Management::Space }
        end
        it 'returns the space for a given key' do
          vcr(:get_space) do
            space = subject.find(space_id)
            expect(space.id).to eql space_id
          end
        end
        it 'returns an error when space not exists' do
          vcr(:delete_space_not_found) do
            result = subject.find('not_exist')
            expect(result).to be_kind_of Contentful::NotFound
          end
        end
      end

      describe '#destroy' do
        it 'returns true when a space was deleted' do
          vcr(:delete_space_success) do
            result = subject.find('7ey2ax4nli32').destroy
            expect(result).to eql true
          end
        end
      end

      describe '.create' do
        let(:space_name) { 'My Test Space' }
        let(:organization_id) { '5Ct8QHndDsi4zT3hwFwOLd' }

        it 'creates a space within an organization' do
          vcr(:create_space) do
            space = subject.create(name: space_name, organization_id: organization_id)
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
        it 'returns error when user have multiple organizations and not pass organization_id' do
          vcr(:create_space_to_unknown_organization) do
            space = subject.create(name: space_name)
            expect(space).to be_kind_of Contentful::NotFound
          end
        end
        it 'returns error when limit has been reached' do
          vcr(:create_space_when_limit_has_been_reached) do
            space = subject.create({name: space_name})
            expect(space).to be_kind_of Contentful::AccessDenied
          end
        end
      end

      describe '#update' do
        it 'updates the space name and increase version by +1' do
          vcr(:update_space) do
            space = subject.find(space_id)
            initial_version = space.sys[:version]
            space.update(name: 'NewNameSpace')
            expect(space.sys[:version]).to eql initial_version + 1
          end
        end
        it 'update name to the same name not increase version' do
          vcr(:update_space_with_the_same_data) do
            space = subject.find(space_id)
            initial_version = space.sys[:version]
            space.update(name: 'NewNameSpacee')
            expect(space.sys[:version]).to eql initial_version
          end
        end
      end

      describe '#content_types' do
        it 'lists content types to given space' do
          vcr(:get_content_types) do
            content_types = subject.find(space_id).content_types
            expect(content_types).to be_kind_of Contentful::Array
          end
        end
        it 'builds a Contentful::Management::ContentType object' do
          vcr(:get_content_types) { expect(subject.find(space_id).content_types.first).to be_kind_of Contentful::Management::ContentType }
        end
      end

      describe '#locales' do
        it 'lists locales to given space' do
          vcr(:get_locales) do
            content_types = subject.find(space_id).locales
            expect(content_types).to be_kind_of Contentful::Array
          end
        end
        it 'builds a Contentful::Management::Local object' do
          vcr(:get_locales) { expect(subject.find(space_id).locales.first).to be_kind_of Contentful::Management::Locale }
        end
      end
      describe '#save' do
        let(:new_name) { 'SaveNewName' }
        it 'successfully save an object' do
          vcr(:save_update_space) do
            content_types = subject.find(space_id)
            content_types.name = 'UpdateNameBySave'
            content_types.save
            expect(content_types).to be_kind_of Contentful::Management::Space
          end
        end
        it 'successfully save an object' do
          vcr(:save_new_space) do
            space = subject.new
            space.name = new_name
            space.save
            expect(space).to be_kind_of Contentful::Management::Space
            expect(space.name).to eq new_name
          end
        end
      end
    end
  end
end