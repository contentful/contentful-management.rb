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

      describe '.find' do
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
            space = subject.create(name: space_name)
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
            space = subject.create(name: space_name)
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
        let(:content_type_id) { 'LE3x1rgCgU6QO0guSEm64' }
        let(:content_type_name) { 'TestingContentType' }

        it 'creates content type' do
          vcr(:space_content_types_create) do
            content_type = subject.find(space_id).content_types.create(name: content_type_name)
            expect(content_type).to be_kind_of Contentful::Management::ContentType
            expect(content_type.name).to eq content_type_name
          end
        end

        it 'lists content types to given space' do
          vcr(:get_content_types) do
            content_types = subject.find(space_id).content_types
            expect(content_types).to be_kind_of Contentful::Array
          end
        end
        it 'builds a Contentful::Management::ContentType object' do
          vcr(:get_content_types) { expect(subject.find(space_id).content_types.first).to be_kind_of Contentful::Management::ContentType }
        end
        it '#content_types.find' do
          vcr(:content_types_find) do
            content_type = subject.find(space_id).content_types.find(content_type_id)
            expect(content_type).to be_kind_of Contentful::Management::ContentType
            expect(content_type.name).to eq content_type_name
          end
        end
        it '.content_types.all' do
          vcr(:get_content_types_all) do
            content_types = subject.find(space_id).content_types.all
            expect(content_types).to be_kind_of Contentful::Array
          end
        end
      end

      describe '#locales' do
        let(:locale_id) { '5lxE2NYGbYiaerH8dx3WNE' }
        it 'lists locales to given space' do
          vcr(:get_locales) do
            locales = subject.find(space_id).locales
            expect(locales).to be_kind_of Contentful::Array
          end
        end
        it 'builds a Contentful::Management::Local object' do
          vcr(:get_locales) { expect(subject.find(space_id).locales.first).to be_kind_of Contentful::Management::Locale }
        end

        it '#locales.all' do
          vcr(:get_locales_all) do
            locales = subject.find(space_id).locales.all
            expect(locales).to be_kind_of Contentful::Array
          end
        end
        it 'builds a Contentful::Management::Local object' do
          vcr(:get_locales_all) { expect(subject.find(space_id).locales.all.first).to be_kind_of Contentful::Management::Locale }
        end
        it '#locales.find' do
          vcr(:locales_find) do
            locales = subject.find(space_id).locales.find(locale_id)
            expect(locales).to be_kind_of Contentful::Management::Locale
            expect(locales.code).to eql 'en-US'
          end
        end

        it 'when locale not found' do
          vcr(:locale_not_found) do
            locale = subject.find(space_id).locales.find('invalid_id')
            expect(locale).to be_kind_of Contentful::NotFound
          end
        end

        it 'creates locales to space' do
          vcr(:locale_create) do
            locale = subject.find(space_id).locales.create(name: 'testLocaleBelgiumNl', contentManagementApi: true, publish: true, contentDeliveryApi: true, code: 'nl')
            expect(locale).to be_kind_of Contentful::Management::Locale
            expect(locale.name).to eql 'testLocaleBelgiumNl'
          end
        end

        it 'returns error when locale already exists' do
          vcr(:locale_create_with_same_code) do
            locale = subject.find(space_id).locales.create(name: 'testLocaleBelgiumNl', contentManagementApi: true, publish: true, contentDeliveryApi: true, code: 'nl')
            expect(locale).to be_kind_of Contentful::Error
          end
        end

        it '#update when all params are given' do
          vcr(:locale_update) do
            locale = subject.find(space_id).locales.find('0X5xcjckv6RMrd9Trae81p')
            initial_version = locale.sys[:version]
            locale.update(name: 'testNewLocaleNameUpdate', contentManagementApi: true, publish: true, contentDeliveryApi: false)
            expect(locale).to be_kind_of Contentful::Management::Locale
            expect(locale.name).to eql 'testNewLocaleNameUpdate'
            expect(locale.sys[:version]).to eql initial_version + 1
          end
        end

        it '#update name' do
          vcr(:locale_update_only_name) do
            locale = subject.find(space_id).locales.find('0X5xcjckv6RMrd9Trae81p')
            locale.update(name: 'testNewLocaleName')
            expect(locale).to be_kind_of Contentful::Management::Locale
            expect(locale.name).to eql 'testNewLocaleName'
          end
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
