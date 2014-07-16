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
            expect(content_type.active?).to be_truthy
          end
        end
        it 'returns false if content_type is not active' do
          vcr(:deactivate_content_type) do
            content_type = subject.find(space_id, content_type_id)
            content_type.deactivate
            expect(content_type.active?).to be_falsey
          end
        end
      end

      describe '.create' do
        let(:content_type_name) { 'My Content Type' }
        let(:content_type_description) { 'My Description' }

        it 'creates a content_type within a space without id and without fields' do
          vcr(:create_content_type) do
            content_type = Contentful::Management::ContentType.create(space_id, name: content_type_name, description: content_type_description)
            expect(content_type).to be_kind_of Contentful::Management::ContentType
            expect(content_type.name).to eq content_type_name
            expect(content_type.description).to eq content_type_description
          end
        end

        it 'creates a content_type within a space with custom id and without fields' do
          vcr(:create_content_type_with_id) do
            content_type_id = 'custom_id'
            content_type = Contentful::Management::ContentType.create(space_id, {name: content_type_name, id: content_type_id})
            expect(content_type).to be_kind_of Contentful::Management::ContentType
            expect(content_type.name).to eq content_type_name
            expect(content_type.id).to eq content_type_id
          end
        end

        [:symbol, :text, :integer, :float, :date, :boolean, :link, :array, :object].each do |field_type|
          it "creates a content_type within a space with #{field_type} field" do
            vcr("create_content_type_with_#{field_type}_field") do
              field = Contentful::Management::Field.new
              field.id = "my_#{field_type}_field"
              field.name = "My #{field_type} Field"
              field.type = field_type.to_s
              content_type = Contentful::Management::ContentType.create(space_id, name: content_type_name, fields: [field])
              expect(content_type).to be_kind_of Contentful::Management::ContentType
              expect(content_type.name).to eq content_type_name
              expect(content_type.fields.size).to eq 1
              result_field = content_type.fields.first
              expect(result_field.id).to eq field.id
              expect(result_field.name).to eq field.name
              expect(result_field.type).to eq field.type
            end
          end
        end
      end

      describe '#update' do
        let(:content_type_name) { 'My New Content Type' }
        let(:content_type_description) { 'My New Description' }
        it 'updates content_type name and description' do
          vcr(:update_content_type) do
            content_type_id = '4WbIShZ6dW68UGqi8sCyMA'
            content_type = subject.find(space_id, content_type_id)
            content_type.update(name: content_type_name, description: content_type_description)
            expect(content_type.name).to eq content_type_name
            expect(content_type.description).to eq content_type_description
          end
        end

        it 'updates content_type with fields (leave fields untouched)' do
          vcr(:update_content_type_with_fields) do
            content_type_id = '4WbIShZ6dW68UGqi8sCyMA'
            content_type = subject.find(space_id, content_type_id)
            content_type.update(name: content_type_name)
            expect(content_type.name).to eq content_type_name
            expect(content_type.fields.size).to eq 1
          end
        end

        it 'updates content_type adding one field' do
          vcr(:update_content_type_with_one_new_field) do
            field = Contentful::Management::Field.new
            field.id = 'second_text_field'
            field.name = 'My Second Text Field'
            field.type = 'Text'
            content_type_id = '1J3i0rr6huqKc8yGMq22QI'
            content_type = subject.find(space_id, content_type_id)
            content_type.update(fields: content_type.fields + [field])
            expect(content_type.fields.size).to eq 2
          end
        end

        it 'updates content_type updating existing field' do
          vcr(:update_content_type_change_field_name) do
            new_field_name = 'New field name'
            content_type_id = '1J3i0rr6huqKc8yGMq22QI'
            content_type = subject.find(space_id, content_type_id)
            field = content_type.fields.first
            field.name = new_field_name
            content_type.update(fields: [field])
            expect(content_type.fields.size).to eq 1
            expect(content_type.fields.first.name).to eq new_field_name
          end
        end

        it 'updates content_type deleting existing field' do
          vcr(:update_content_type_remove_field) do
            content_type_id = '1J3i0rr6huqKc8yGMq22QI'
            content_type = subject.find(space_id, content_type_id)
            field = content_type.fields.first
            content_type.update(fields: [field])
            expect(content_type.fields.size).to eq 1
          end
        end
      end

      describe '#save' do
        let(:new_name) { 'NewName' }
        it 'saves existing object' do
          vcr(:save_existing_content_type) do
            content_type = subject.find(space_id, content_type_id)
            content_type.name = new_name
            content_type.save
            expect(content_type).to be_kind_of Contentful::Management::ContentType
            expect(content_type.name).to eq new_name
          end
        end

        it 'saves object with new field' do
          vcr(:save_existing_content_type_adding_field) do
            content_type = subject.find(space_id, content_type_id)
            field = Contentful::Management::Field.new
            field.id = 'my_text_field'
            field.name = 'My Text Field'
            field.type = 'Text'
            content_type.fields = content_type.fields + [field]
            content_type.save
            expect(content_type).to be_kind_of Contentful::Management::ContentType
            expect(content_type.name).to eq new_name
            expect(content_type.fields.size).to eq 2
          end
        end

        it 'successfully saves new object' do
          vcr(:save_new_content_type) do
            space = Contentful::Management::Space.find(space_id)
            content_type = space.content_types.new
            content_type.name = new_name
            field = Contentful::Management::Field.new
            field.id = 'my_text_field'
            field.name = 'My Text Field'
            field.type = 'Text'
            content_type.fields = [field]
            content_type.save
            expect(content_type).to be_kind_of Contentful::Management::ContentType
            expect(content_type.name).to eq new_name
            expect(content_type.fields.size).to eq 1
          end
        end
      end

      describe '#fields.create' do
        let(:field_id) { 'my_text_field_1' }
        let(:field_type) { 'Text' }
        it 'creates new field' do
          vcr(:content_type_fields_create) do
            content_type = subject.find(space_id, '41cG5MFEb6e4wQy0sg8Mww')
            content_type.fields.create(id: field_id, name: 'My Text Field', type: field_type)
            expect(content_type.fields.size).to eq 2
          end
        end
        it 'updates existing field if matched id' do
          vcr(:content_type_fields_create) do
            content_type = subject.find(space_id, '41cG5MFEb6e4wQy0sg8Mww')
            updated_name = 'My Text Field 2'
            content_type.fields.create(id: field_id, name: updated_name, type: field_type)
            expect(content_type.fields.size).to eq 2
            expect(content_type.fields[1].name).to eq updated_name
            expect(content_type.fields[1].type).to eq field_type
          end
        end
      end

      describe '#fields.add' do
        it 'creates new field' do
          vcr(:content_type_fields_add) do
            content_type = subject.find(space_id, '41cG5MFEb6e4wQy0sg8Mww')
            field = Contentful::Management::Field.new
            field.id = 'my_text_field_2'
            field.name = 'My Text Field'
            field.type = 'Text'
            content_type.fields.add(field)
            expect(content_type.fields.size).to eq 3
          end
        end
      end

      describe '#fields.destroy' do
        it 'deletes field by id' do
          vcr(:content_type_fields_destroy) do
            content_type = subject.find(space_id, '41cG5MFEb6e4wQy0sg8Mww')
            content_type.fields.destroy('tf1')
            expect(content_type.fields.size).to eq 0
          end
        end
      end
    end
  end
end