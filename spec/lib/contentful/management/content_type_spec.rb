require 'spec_helper'
require 'contentful/management/space'
require 'contentful/management/client'

module Contentful
  module Management
    describe ContentType do
      let(:token) { '91c6eeeca517239cd4b374a9ad2d62c1455def4551bf77e76cfd359a81aa6185' }
      let(:space_id) { 'btp9v9jxpknp' }
      let(:content_type_id) { '41cG5MFEb6e4wQy0sg8Mww' }

      let!(:client) { Client.new(token) }

      subject { Contentful::Management::ContentType }

      describe '.all' do
        it 'returns a Contentful::Array' do
          vcr(:get_content_types_for_space) { expect(subject.all(space_id)).to be_kind_of Contentful::Array }
        end
        it 'builds a Contentful::Management::ContentType object' do
          vcr(:get_content_types_for_space) { expect(subject.all(space_id).first).to be_kind_of Contentful::Management::ContentType }
        end
      end

      describe '#find' do
        it 'returns a Contentful::Management::ContentType' do
          vcr(:get_content_type) { expect(subject.find(space_id, content_type_id)).to be_kind_of Contentful::Management::ContentType }
        end
        it 'returns the content_type for a given key' do
          vcr(:get_content_type) do
            content_type = subject.find(space_id, content_type_id)
            expect(content_type.id).to eql content_type_id
          end
        end
        it 'returns an error when content_type does not exists' do
          vcr(:content_type_not_found) do
            result = subject.find(space_id, 'not_exist')
            expect(result).to be_kind_of Contentful::NotFound
          end
        end
      end

      describe '#destroy' do
        it 'returns Contentful::BadRequest error when content type is published' do
          vcr(:delete_content_type_published) do
            result = subject.find(space_id, '2eg6tcVdPiKMYkAcMU2wQq').destroy
            expect(result).to be_kind_of Contentful::BadRequest
          end
        end
        it 'returns error message when content type is published' do
          vcr(:delete_content_type_published) do
            result = subject.find(space_id, '2eg6tcVdPiKMYkAcMU2wQq').destroy
            expect(result.message).to eq 'Cannot deleted published'
          end
        end
        it 'returns true when content type is not published' do
          vcr(:delete_content_type_success) do
            result = subject.find(space_id, '2eg6tcVdPiKMYkAcMU2wQq').destroy
            expect(result).to eql true
          end
        end
      end

      describe '#activate' do
        it 'returns Contentful::Management::ContentType' do
          vcr(:activate_content_type) do
            result = subject.find(space_id, content_type_id).activate
            expect(result).to be_kind_of Contentful::Management::ContentType
          end
        end
        it 'increases object version' do
          vcr(:activate_content_type) do
            content_type = subject.find(space_id, content_type_id)
            initial_version = content_type.sys[:version]
            content_type.activate
            expect(content_type.sys[:version]).to eql initial_version + 1
          end
        end
        it 'returns BadRequest error when not valid version' do
          vcr(:activate_content_type_invalid_version) do
            content_type = subject.find(space_id, content_type_id)
            content_type.sys[:version] = -1
            result = content_type.activate
            expect(result).to be_kind_of Contentful::BadRequest
          end
        end
      end

      describe '#deactivate' do
        it 'returns Contentful::Management::ContentType' do
          vcr(:deactivate_content_type) do
            content_type = subject.find(space_id, content_type_id)
            result = content_type.deactivate
            expect(result).to be_kind_of Contentful::Management::ContentType
          end
        end
        it 'increases object version' do
          vcr(:deactivate_content_type_with_version_change) do
            content_type = subject.find(space_id, content_type_id)
            initial_version = content_type.sys[:version]
            content_type.activate
            expect(content_type.sys[:version]).to eql initial_version + 1
          end
        end
        it 'returns BadRequest error when already unpublished' do
          vcr(:deactivate_content_type_already_unpublished) do
            result = subject.find(space_id, content_type_id).deactivate
            expect(result).to be_kind_of Contentful::BadRequest
          end
        end
        it 'returns error message when already unpublished' do
          vcr(:deactivate_content_type_already_unpublished) do
            content_type = subject.find(space_id, content_type_id)
            content_type.sys[:version] = -1
            result = content_type.deactivate
            expect(result.message).to eq 'Not published'
          end
        end
      end

      describe '#active?' do
        it 'returns true if content_type is active' do
          vcr(:activate_content_type) do
            content_type = subject.find(space_id, content_type_id)
            content_type.activate
            expect(content_type.active?).to be_true
          end
        end
        it 'returns false if content_type is not active' do
          vcr(:deactivate_content_type) do
            content_type = subject.find(space_id, content_type_id)
            content_type.deactivate
            expect(content_type.active?).to be_false
          end
        end
      end


      # describe '.create' do
      #   let(:space_name) { 'My Test Space' }
      #   let(:organization_id) { '5Ct8QHndDsi4zT3hwFwOLd' }
      #
      #   it 'creates a space within an organization' do
      #     vcr(:create_space) do
      #       space = subject.create(name: space_name, organization_id: organization_id)
      #       expect(space).to be_kind_of Contentful::Management::Space
      #       expect(space.name).to eq space_name
      #     end
      #   end
      #   it 'creates a space when the user only has one organization' do
      #     vcr(:create_space_without_organization) do
      #       space = subject.create({name: space_name})
      #       expect(space).to be_kind_of Contentful::Management::Space
      #       expect(space.name).to eq space_name
      #     end
      #   end
      #   it 'returns error when user have multiple organizations and not pass organization_id' do
      #     vcr(:create_space_to_unknown_organization) do
      #       space = subject.create(name: space_name)
      #       expect(space).to be_kind_of Contentful::NotFound
      #     end
      #   end
      #   it 'returns error when limit has been reached' do
      #     vcr(:create_space_when_limit_has_been_reached) do
      #       space = subject.create({name: space_name})
      #       expect(space).to be_kind_of Contentful::AccessDenied
      #     end
      #   end
      # end
      #
      # describe '#update' do
      #   it 'updates the space name and increase version by +1' do
      #     vcr(:update_space) do
      #       space = subject.find(space_id)
      #       initial_version = space.sys[:version]
      #       space.update(name: 'NewNameSpace')
      #       expect(space.sys[:version]).to eql initial_version + 1
      #     end
      #   end
      #   it 'update name to the same name not increase version' do
      #     vcr(:update_space_with_the_same_data) do
      #       space = subject.find(space_id)
      #       initial_version = space.sys[:version]
      #       space.update(name: 'NewNameSpacee')
      #       expect(space.sys[:version]).to eql initial_version
      #     end
      #   end
      # end
      #
      # describe '#save' do
      #   let(:new_name) { 'SaveNewName' }
      #   it 'successfully save an object' do
      #     vcr(:save_update_space) do
      #       content_types = subject.find(space_id)
      #       content_types.name = 'UpdateNameBySave'
      #       content_types.save
      #       expect(content_types).to be_kind_of Contentful::Management::Space
      #     end
      #   end
      #   it 'successfully save an object' do
      #     vcr(:save_new_space) do
      #       space = subject.new
      #       space.name = new_name
      #       space.save
      #       expect(space).to be_kind_of Contentful::Management::Space
      #       expect(space.name).to eq new_name
      #     end
      #   end
      # end

    end
  end
end
