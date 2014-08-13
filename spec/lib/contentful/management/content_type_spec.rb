# -*- encoding: utf-8 -*-
require 'spec_helper'
require 'contentful/management/space'
require 'contentful/management/client'

module Contentful
  module Management
    describe ContentType do
      let(:token) { '<ACCESS_TOKEN>' }
      let(:space_id) { 'yr5m0jky5hsh' }
      let!(:client) { Client.new(token) }
      let(:content_type_id) { '5DSpuKrl04eMAGQoQckeIq' }

      subject { Contentful::Management::ContentType }

      describe '.all' do
        it 'returns a Contentful::Array' do
          vcr('content_type/all') { expect(subject.all(space_id)).to be_kind_of Contentful::Management::Array }
        end
        it 'builds a Contentful::Management::ContentType object' do
          vcr('content_type/all') { expect(subject.all(space_id).first).to be_kind_of Contentful::Management::ContentType }
        end
      end

      describe '#find' do
        it 'returns a Contentful::Management::ContentType' do
          vcr('content_type/find') { expect(subject.find(space_id, content_type_id)).to be_kind_of Contentful::Management::ContentType }
        end
        it 'returns the content_type for a given key' do
          vcr('content_type/find') do
            content_type = subject.find(space_id, content_type_id)
            expect(content_type.id).to eql content_type_id
          end
        end
        it 'returns an error when content_type does not found' do
          vcr('content_type/find_not_found') do
            result = subject.find(space_id, 'not_exist')
            expect(result).to be_kind_of Contentful::Management::NotFound
          end
        end
      end

      describe '#destroy' do
        it 'returns Contentful::BadRequest error when content type is activated' do
          vcr('content_type/destroy_activated') do
            result = subject.find(space_id, '66jvD8UhNKmWGk24KKq0EW').destroy
            expect(result).to be_kind_of Contentful::Management::BadRequest
            expect(result.message).to eq 'Cannot deleted published'
          end
        end

        it 'returns true when content type is not activated' do
          vcr('content_type/destroy') do
            result = subject.find(space_id, '66jvD8UhNKmWGk24KKq0EW').destroy
            expect(result).to eql true
          end
        end
      end

      describe '#activate' do
        let(:active_content) { '4EnwylPOikyMGUIy8uQgQY' }
        it 'returns Contentful::Management::ContentType' do
          vcr('content_type/activate') do
            result = subject.find(space_id, active_content).activate
            expect(result).to be_kind_of Contentful::Management::ContentType
          end
        end
        it 'increases object version' do
          vcr('content_type/activate') do
            content_type = subject.find(space_id, active_content)
            initial_version = content_type.sys[:version]
            content_type.activate
            expect(content_type.sys[:version]).to eql initial_version + 1
          end
        end
        it 'returns error when not valid version' do
          vcr('content_type/activate_with_invalid_version') do
            content_type = subject.find(space_id, active_content)
            content_type.sys[:version] = -1
            result = content_type.activate
            expect(result).to be_kind_of Contentful::Management::BadRequest
          end
        end
      end

      describe '#deactivate' do
        let(:deactivate_content) { '4EnwylPOikyMGUIy8uQgQY' }
        it 'returns Contentful::Management::ContentType' do
          vcr('content_type/deactivate') do
            content_type = subject.find(space_id, deactivate_content)
            result = content_type.deactivate
            expect(result).to be_kind_of Contentful::Management::ContentType
          end
        end
        it 'increases object version' do
          vcr('content_type/deactivate_with_version_change') do
            content_type = subject.find(space_id, deactivate_content)
            initial_version = content_type.sys[:version]
            content_type.activate
            expect(content_type.sys[:version]).to eql initial_version + 1
          end
        end
        it 'returns error when has entries' do
          vcr('content_type/deactivate_with_entries') do
            result = subject.find(space_id, '5DSpuKrl04eMAGQoQckeIq').deactivate
            expect(result).to be_kind_of Contentful::Management::BadRequest
          end
        end
        it 'returns error message when already deactivated' do
          vcr('content_type/deactivate_already_deactivated') do
            content_type = subject.find(space_id, deactivate_content)
            content_type.sys[:version] = -1
            result = content_type.deactivate
            expect(result.message).to eq 'Not published'
          end
        end
      end

      describe '#active?' do
        it 'returns true if content_type is active' do
          vcr('content_type/activated_true') do
            content_type = subject.find(space_id, '4EnwylPOikyMGUIy8uQgQY')
            content_type.activate
            expect(content_type.active?).to be_truthy
          end
        end
        it 'returns false if content_type is not active' do
          vcr('content_type/activated_false') do
            content_type = subject.find(space_id, '4EnwylPOikyMGUIy8uQgQY')
            content_type.deactivate
            expect(content_type.active?).to be_falsey
          end
        end
      end

      describe '.create' do
        let(:content_type_name) { 'Blog' }
        let(:content_type_description) { 'Blog content type' }

        it 'creates a content_type within a space without id and without fields' do
          vcr('content_type/create') do
            content_type = Contentful::Management::ContentType.create(space_id, name: content_type_name, description: content_type_description)
            expect(content_type).to be_kind_of Contentful::Management::ContentType
            expect(content_type.name).to eq content_type_name
            expect(content_type.description).to eq content_type_description
          end
        end

        it 'creates a content_type within a space with custom id and without fields' do
          vcr('content_type/create_content_type_with_id') do
            content_type_id = 'custom_id'
            content_type = Contentful::Management::ContentType.create(space_id, { name: content_type_name,
                                                                                  id: content_type_id })
            expect(content_type).to be_kind_of Contentful::Management::ContentType
            expect(content_type.name).to eq content_type_name
            expect(content_type.id).to eq content_type_id
          end
        end

        Contentful::Management::ContentType::FIELD_TYPES.each do |field_type|
          it "creates within a space with #{ field_type } field" do
            vcr("content_type/create_with_#{ field_type }_field") do
              field = Contentful::Management::Field.new
              field.id = "my_#{ field_type }_field"
              field.name = "My #{ field_type } Field"
              field.type = field_type
              field.link_type = 'Entry' if field_type == 'Link'
              content_type = Contentful::Management::ContentType.create(space_id, name: "#{ field_type }",
                                                                        description: "Content type with #{ field_type } field",
                                                                        fields: [field])
              expect(content_type).to be_kind_of Contentful::Management::ContentType
              expect(content_type.name).to eq "#{ field_type }"
              expect(content_type.description).to eq "Content type with #{ field_type } field"
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
        let(:content_type_name) { 'Blog Content' }
        let(:content_type_description) { 'Blogs content type' }
        let(:content_type_id) { 'qw3F2rn3FeoOiceqAiCSC' }
        it 'updates content_type name and description' do
          vcr('content_type/update') do
            content_type = subject.find(space_id, content_type_id)
            content_type.update(name: content_type_name, description: content_type_description)
            expect(content_type.name).to eq content_type_name
            expect(content_type.description).to eq content_type_description
          end
        end

        it 'updates content_type with fields (leave fields untouched)' do
          vcr('content_type/update_with_fields') do
            content_type = subject.find(space_id, content_type_id)
            content_type.update(name: content_type_name)
            expect(content_type.name).to eq content_type_name
            expect(content_type.fields.size).to eq 2
          end
        end

        it 'updates content_type adding one field' do
          vcr('content_type/update_with_one_new_field') do
            field = Contentful::Management::Field.new
            field.id = 'blog_author'
            field.name = 'Author of blog'
            field.type = 'Text'
            content_type = subject.find(space_id, content_type_id)
            content_type.update(fields: content_type.fields + [field])
            expect(content_type.fields.size).to eq 5
          end
        end

        it 'updates content_type updating existing field' do
          vcr('content_type/update_change_field_name') do
            new_field_name = 'blog_author'
            content_type = subject.find(space_id, content_type_id)
            field = content_type.fields.first
            field.name = new_field_name
            content_type.update(fields: content_type.fields)
            expect(content_type.fields.size).to eq 2
            expect(content_type.fields.first.name).to eq new_field_name
          end
        end

        it 'updates content_type deleting existing field' do
          vcr('content_type/update_remove_field') do
            content_type = subject.find(space_id, content_type_id)
            field = content_type.fields.first
            content_type.update(fields: [field])
            expect(content_type.fields.size).to eq 1
          end
        end
      end

      describe '#save' do
        it 'updated content type' do
          vcr('content_type/save_updated') do
            content_type = subject.find(space_id, content_type_id)
            content_type.name = 'NewName'
            content_type.save
            expect(content_type).to be_kind_of Contentful::Management::ContentType
            expect(content_type.name).to eq 'NewName'
          end
        end

        it 'with new field' do
          vcr('content_type/save_with_added_field') do
            content_type = subject.find(space_id, '2tDzYAg5MM6sIkwsOmM0Kc')
            field = Contentful::Management::Field.new
            field.id = 'blog_title'
            field.name = 'Blog Title'
            field.type = 'Text'
            content_type.fields = content_type.fields + [field]
            content_type.save
            expect(content_type).to be_kind_of Contentful::Management::ContentType
            expect(content_type.name).to eq 'Blog testing'
            expect(content_type.fields.size).to eq 2
          end
        end

        it 'saves new object' do
          vcr('content_type/save_new') do
            space = Contentful::Management::Space.find(space_id)
            content_type = space.content_types.new
            content_type.name = 'Post title'
            field = Contentful::Management::Field.new
            field.id = 'my_text_field'
            field.name = 'My Text Field'
            field.type = 'Text'
            content_type.fields = [field]
            content_type.save
            expect(content_type).to be_kind_of Contentful::Management::ContentType
            expect(content_type.name).to eq 'Post title'
            expect(content_type.fields.size).to eq 1
          end
        end
      end

      describe '#fields.create' do
        let(:field_id) { 'eye_color' }
        let(:field_type) { 'Text' }
        it 'creates new field' do
          vcr('content_type/fields/create') do
            content_type = subject.find(space_id, content_type_id)
            content_type.fields.create(id: field_id, name: 'Eye color', type: field_type)
            expect(content_type.fields.size).to eq 12
          end
        end
        it 'creates new Link field with additional parameters' do
          vcr('content_type/fields/create_with_params') do
            content_type = subject.find(space_id, 'qw3F2rn3FeoOiceqAiCSC')
            content_type.fields.create(id: 'blog_avatar', name: 'Blog avatar',
                                       type: 'Link',
                                       link_type: 'Asset',
                                       localized: true,
                                       required: true)
            expect(content_type.fields.size).to eq 2
            field = content_type.fields.last
            expect(field.name).to eq 'Blog avatar'
            expect(field.type).to eq 'Link'
            expect(field.link_type).to eq 'Asset'
            expect(field.localized).to be_truthy
            expect(field.required).to be_truthy
          end
        end
        it 'creates new Array field with additional parameters' do
          vcr('content_type/fields/create_array_with_params') do
            content_type = subject.find(space_id, '6xzrdCr33OMAeIYUgs6UKi')
            items = Contentful::Management::Field.new
            items.type = 'Link'
            items.link_type = 'Entry'
            content_type.fields.create(id: 'blog_entries', name: 'Entries', type: 'Array', localized: true, items: items)
            expect(content_type.fields.size).to eq 2
            field = content_type.fields.last
            expect(field.name).to eq 'Entries'
            expect(field.type).to eq 'Array'
            expect(field.items.type).to eq items.type
          end
        end
        it 'updates existing field if matched id' do
          vcr('content_type/fields/update_field') do
            content_type = subject.find(space_id, '5DSpuKrl04eMAGQoQckeIq')
            updated_name = 'Eyes color'
            content_type.fields.create(id: field_id, name: updated_name, type: field_type)
            expect(content_type.fields.size).to eq 12
            expect(content_type.fields[11].name).to eq updated_name
            expect(content_type.fields[11].type).to eq field_type
          end
        end
      end

      describe '#fields.add' do
        it 'creates new field' do
          vcr('content_type/fields/add') do
            content_type = subject.find(space_id, content_type_id)
            field = Contentful::Management::Field.new
            field.id = 'symbol'
            field.name = 'Symbol'
            field.type = 'Symbol'
            field.localized = true
            field.required = true
            content_type.fields.add(field)
            expect(content_type.fields.size).to eq 11
          end
        end
      end

      describe '#fields.destroy' do
        it 'deletes field by id' do
          vcr('content_type/fields/destroy') do
            content_type = subject.find(space_id, content_type_id)
            content_type.fields.destroy('blog_title')
            expect(content_type.fields.size).to eq 10
          end
        end
      end

      describe '#entries.create' do
        it 'with Text field' do
          vcr('content_type/entry/create') do
            content_type = subject.find(space_id, content_type_id)
            entry = content_type.entries.create(name: 'Piotrek')
            expect(entry).to be_kind_of Contentful::Management::Entry
            expect(entry.fields[:name]).to eq 'Piotrek'
          end
        end

        it 'with entry' do
          vcr('content_type/entry/create_with_entries') do
            entry_en = Entry.find(space_id, 'Qa8TW5nPWgiU4MA6AGYgq')
            content_type = subject.find(space_id, '6xzrdCr33OMAeIYUgs6UKi')
            entry = content_type.entries.create(blog_name: 'Piotrek',
                                                blog_entry: entry_en,
                                                blog_entries: [entry_en, entry_en, entry_en])
            expect(entry).to be_kind_of Contentful::Management::Entry
            expect(entry.blog_name).to eq 'Piotrek'
            expect(entry.fields[:blog_entry]['sys']['id']).to eq 'Qa8TW5nPWgiU4MA6AGYgq'
            expect(entry.fields[:blog_entries].first['sys']['id']).to eq 'Qa8TW5nPWgiU4MA6AGYgq'
          end
        end
      end

      describe '#entries.new' do
        context 'for  multiple locales' do
          it 'for Text field' do
            vcr('content_type/entry/create_with_multiple_locales') do
              content_type = subject.find(space_id, '4EnwylPOikyMGUIy8uQgQY')
              entry = content_type.entries.new
              entry.post_title_with_locales = { 'en-US' => 'Company logo', 'pl' => 'Firmowe logo' }
              entry.post_body_with_locales = { 'en-US' => 'Story about Contentful...', 'pl' => 'Historia o Contentful...' }
              entry.save

              expect(entry).to be_kind_of Contentful::Management::Entry
              expect(entry.post_title).to eq 'Company logo'
              expect(entry.post_body).to eq 'Story about Contentful...'
              entry.locale = 'pl'
              expect(entry.post_title).to eq 'Firmowe logo'
              expect(entry.post_body).to eq 'Historia o Contentful...'
            end
          end
          it 'with camel case api id' do
            vcr('content_type/entry/create_with_camel_case_id_to_multiple_locales') do
              content_type = subject.find(space_id, '4esHTHIVgc0uWkiwGwOsa6')
              entry = content_type.entries.new
              entry.car_mark_with_locales = { 'en-US' => 'Mercedes Benz', 'pl' => 'Mercedes' }
              entry.car_city_plate_with_locales = { 'en-US' => 'en', 'pl' => 'bia' }
              entry.car_capacity_with_locales = { 'en-US' => 2.5, 'pl' => 2.5 }
              entry.save

              expect(entry).to be_kind_of Contentful::Management::Entry
              expect(entry.car_mark).to eq 'Mercedes Benz'
              expect(entry.car_city_plate).to eq 'en'
              expect(entry.car_capacity).to eq 2.5
              entry.locale = 'pl'
              expect(entry.car_mark).to eq 'Mercedes'
              expect(entry.car_city_plate).to eq 'bia'
              expect(entry.car_capacity).to eq 2.5
            end
          end
          it 'with entries' do
            vcr('content_type/entry/create_with_entries_for_multiple_locales') do
              space = Contentful::Management::Space.find(space_id)
              space.content_types # filling cache

              entry_en = space.entries.find('664EPJ6zHqAeMO6O0mGggU')
              entry_pl = space.entries.find('664EPJ6zHqAeMO6O0mGggU')

              content_type = space.content_types.find('6xzrdCr33OMAeIYUgs6UKi')
              entry = content_type.entries.new
              entry.blog_name_with_locales = { 'en-US' => 'Contentful en', 'pl' => 'Contentful pl' }
              entry.blog_entries_with_locales = { 'en-US' => [entry_en, entry_en], 'pl' => [entry_pl, entry_pl] }
              entry.blog_entry_with_locales = { 'en-US' => entry_en, 'pl' => entry_pl }
              entry.save
              expect(entry.blog_name).to eq 'Contentful en'
            end
          end

          it 'with assets' do
            vcr('content_type/entry/create_with_entries_for_multiple_locales') do
              space = Contentful::Management::Space.find(space_id)
              space.content_types # filling cache

              entry_en = space.entries.find('664EPJ6zHqAeMO6O0mGggU')
              entry_pl = space.entries.find('664EPJ6zHqAeMO6O0mGggU')

              content_type = space.content_types.find('6xzrdCr33OMAeIYUgs6UKi')
              entry = content_type.entries.new
              entry.blog_name_with_locales = { 'en-US' => 'Contentful en', 'pl' => 'Contentful pl' }
              entry.blog_entries_with_locales = { 'en-US' => [entry_en, entry_en], 'pl' => [entry_pl, entry_pl] }
              entry.blog_entry_with_locales = { 'en-US' => entry_en, 'pl' => entry_pl }
              entry.save
              expect(entry.blog_name).to eq 'Contentful en'
            end
          end
        end
      end

      describe '#entries.all' do
        let(:space_id) { '9lxkhjnp8gyx' }

         it 'returns entries' do
           vcr('content_type/entry/all') do
             space = Contentful::Management::Space.find(space_id)
             content_type = space.content_types.find('category_content_type')
             entries = content_type.entries.all
             expect(entries).to be_kind_of Contentful::Management::Array
             expect(entries.size).to eq 2
             expect(entries.first).to be_kind_of Contentful::Management::Entry
             expect(entries.first.sys[:contentType].id).to eq 'category_content_type'
           end
         end
      end
    end
  end
end
