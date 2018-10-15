require 'spec_helper'
require 'contentful/management/space'
require 'contentful/management/client'

module Contentful
  module Management
    describe ContentType do
      let(:token) { ENV.fetch('CF_TEST_CMA_TOKEN', '<ACCESS_TOKEN>') }
      let(:space_id) { 'yr5m0jky5hsh' }
      let!(:client) { Client.new(token) }
      let(:content_type_id) { '5DSpuKrl04eMAGQoQckeIq' }

      subject { client.content_types(space_id, 'master') }

      describe '.all' do
        it 'class method also works' do
          vcr('content_type/all') { expect(Contentful::Management::ContentType.all(client, space_id, 'master')).to be_kind_of Contentful::Management::Array }
        end
        it 'returns a Contentful::Array' do
          vcr('content_type/all') { expect(subject.all).to be_kind_of Contentful::Management::Array }
        end
        it 'builds a Contentful::Management::ContentType object' do
          vcr('content_type/all') { expect(subject.all.first).to be_kind_of Contentful::Management::ContentType }
        end
      end

      describe '.all_published' do
        let!(:space_id) { 'bjwq7b86vgmm' }
        it 'class method also works' do
          vcr('content_type/all_public') { expect(Contentful::Management::ContentType.all_published(client, space_id, 'master')).to be_kind_of Contentful::Management::Array }
        end
        it 'returns a Contentful::Array' do
          vcr('content_type/all_public') { expect(subject.all_published).to be_kind_of Contentful::Management::Array }
        end
        it 'builds a Contentful::Management::ContentType object' do
          vcr('content_type/all_public') { expect(subject.all_published.first).to be_kind_of Contentful::Management::ContentType }
        end
      end

      describe '.find' do
        it 'class method also works' do
          vcr('content_type/find') { expect(Contentful::Management::ContentType.find(client, space_id, 'master', content_type_id)).to be_kind_of Contentful::Management::ContentType }
        end
        it 'returns a Contentful::Management::ContentType' do
          vcr('content_type/find') { expect(subject.find(content_type_id)).to be_kind_of Contentful::Management::ContentType }
        end
        it 'returns the content_type for a given key' do
          vcr('content_type/find') do
            content_type = subject.find(content_type_id)
            expect(content_type.id).to eql content_type_id
          end
        end
        it 'returns an error when content_type does not found' do
          vcr('content_type/find_not_found') do
            result = subject.find('not_exist')
            expect(result).to be_kind_of Contentful::Management::NotFound
          end
        end
      end

      describe '#destroy' do
        it 'returns Contentful::BadRequest error when content type is activated' do
          vcr('content_type/destroy_activated') do
            result = subject.find('66jvD8UhNKmWGk24KKq0EW').destroy
            expect(result).to be_kind_of Contentful::Management::BadRequest
            message = [
              "HTTP status code: 400 Bad Request",
              "Message: Cannot delete published"
            ].join("\n")
            expect(result.message).to eq message
          end
        end

        it 'returns true when content type is not activated' do
          vcr('content_type/destroy') do
            result = subject.find('66jvD8UhNKmWGk24KKq0EW').destroy
            expect(result).to eql true
          end
        end
      end

      describe '#activate' do
        let(:active_content) { '4EnwylPOikyMGUIy8uQgQY' }
        it 'returns Contentful::Management::ContentType' do
          vcr('content_type/activate') do
            result = subject.find(active_content).activate
            expect(result).to be_kind_of Contentful::Management::ContentType
          end
        end
        it 'increases object version' do
          vcr('content_type/activate') do
            content_type = subject.find(active_content)
            initial_version = content_type.sys[:version]
            content_type.activate
            expect(content_type.sys[:version]).to eql initial_version + 1
          end
        end
        it 'returns error when not valid version' do
          vcr('content_type/activate_with_invalid_version') do
            content_type = subject.find(active_content)
            content_type.sys[:version] = -1
            result = content_type.activate
            expect(result).to be_kind_of Contentful::Management::Conflict
          end
        end
      end

      describe '#deactivate' do
        let(:deactivate_content) { '4EnwylPOikyMGUIy8uQgQY' }
        it 'returns Contentful::Management::ContentType' do
          vcr('content_type/deactivate') do
            content_type = subject.find(deactivate_content)
            result = content_type.deactivate
            expect(result).to be_kind_of Contentful::Management::ContentType
          end
        end
        it 'increases object version' do
          vcr('content_type/deactivate_with_version_change') do
            content_type = subject.find(deactivate_content)
            initial_version = content_type.sys[:version]
            content_type.activate
            expect(content_type.sys[:version]).to eql initial_version + 1
          end
        end
        it 'returns error when has entries' do
          vcr('content_type/deactivate_with_entries') do
            result = subject.find('5DSpuKrl04eMAGQoQckeIq').deactivate
            expect(result).to be_kind_of Contentful::Management::BadRequest
          end
        end
        it 'returns error message when already deactivated' do
          vcr('content_type/deactivate_already_deactivated') do
            content_type = subject.find(deactivate_content)
            content_type.sys[:version] = -1
            result = content_type.deactivate
            message = [
              "HTTP status code: 400 Bad Request",
              "Message: Not published"
            ].join("\n")
            expect(result.message).to eq message
          end
        end
      end

      describe '#active?' do
        it 'returns true if content_type is active' do
          vcr('content_type/activated_true') do
            content_type = subject.find('4EnwylPOikyMGUIy8uQgQY')
            content_type.activate
            expect(content_type.active?).to be_truthy
          end
        end
        it 'returns false if content_type is not active' do
          vcr('content_type/activated_false') do
            content_type = subject.find('4EnwylPOikyMGUIy8uQgQY')
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
            content_type = subject.create(
              name: content_type_name,
              description: content_type_description
            )
            expect(content_type).to be_kind_of Contentful::Management::ContentType
            expect(content_type.name).to eq content_type_name
            expect(content_type.description).to eq content_type_description
          end
        end

        it 'creates a content_type within a space with custom id and without fields' do
          vcr('content_type/create_content_type_with_id') do
            content_type_id = 'custom_id'
            content_type = subject.create(
              name: content_type_name,
              id: content_type_id
            )
            expect(content_type).to be_kind_of Contentful::Management::ContentType
            expect(content_type.name).to eq content_type_name
            expect(content_type.id).to eq content_type_id
          end
        end

        Contentful::Management::ContentType::FIELD_TYPES.reject { |f| f == 'RichText' }.each do |field_type|
          it "creates within a space with #{ field_type } field" do
            vcr("content_type/create_with_#{ field_type }_field") do
              field = Contentful::Management::Field.new
              field.id = "my_#{ field_type }_field"
              field.name = "My #{ field_type } Field"
              field.type = field_type
              field.link_type = 'Entry' if field_type == 'Link'
              content_type = subject.create(
                name: "#{ field_type }",
                description: "Content type with #{ field_type } field",
                fields: [field]
              )
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

        it "creates within a space with RichText field" do
          vcr("content_type/create_with_RichText_field") do
            subject = client.content_types('ctgv7kwgsghk', 'master')

            field = Contentful::Management::Field.new
            field.id = "my_RichText_field"
            field.name = "My RichText Field"
            field.type = 'RichText'
            content_type = subject.create(
              name: "RichText",
              description: "Content type with RichText field",
              fields: [field]
            )
            expect(content_type).to be_kind_of Contentful::Management::ContentType
            expect(content_type.name).to eq "RichText"
            expect(content_type.description).to eq "Content type with RichText field"
            expect(content_type.fields.size).to eq 1
            result_field = content_type.fields.first
            expect(result_field.id).to eq field.id
            expect(result_field.name).to eq field.name
            expect(result_field.type).to eq field.type
          end
        end

        it 'creates a content_type with an omitted field' do
          vcr('content_type/omitted_field') {
            space = client.spaces.find('ngtgiva4wofg')

            omitted_field = Contentful::Management::Field.new
            omitted_field.id = 'omitted_field'
            omitted_field.name = 'omitted_field'
            omitted_field.type = 'Symbol'
            omitted_field.omitted = true

            name_field = Contentful::Management::Field.new
            name_field.id = 'name'
            name_field.name = 'name'
            name_field.type = 'Symbol'

            content_type = client.content_types(space.id, 'master').create(
              id: 'omitted_ct',
              name: 'Omitted CT',
              fields: [omitted_field, name_field],
              display_field: 'name'
            )

            content_type.activate

            content_type.reload

            field = content_type.fields.detect { |f| f.name == 'omitted_field' }

            expect(field.omitted).to be_truthy

            field = content_type.fields.detect { |f| f.name == 'name' }

            expect(field.omitted).to be_falsey
          }
        end
      end

      describe '#update' do
        let(:content_type_name) { 'Blog Content' }
        let(:content_type_description) { 'Blogs content type' }
        let(:content_type_id) { 'qw3F2rn3FeoOiceqAiCSC' }
        it 'updates content_type name and description' do
          vcr('content_type/update') do
            content_type = subject.find(content_type_id)
            content_type.update(name: content_type_name, description: content_type_description)
            expect(content_type.name).to eq content_type_name
            expect(content_type.description).to eq content_type_description
          end
        end

        it 'updates content_type with fields (leave fields untouched)' do
          vcr('content_type/update_with_fields') do
            content_type = subject.find(content_type_id)
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
            content_type = subject.find(content_type_id)
            content_type.update(fields: content_type.fields + [field])
            expect(content_type.fields.size).to eq 5
          end
        end

        it 'updates content_type updating existing field' do
          vcr('content_type/update_change_field_name') do
            new_field_name = 'blog_author'
            content_type = subject.find(content_type_id)
            field = content_type.fields.first
            field.name = new_field_name
            content_type.update(fields: content_type.fields)
            expect(content_type.fields.size).to eq 2
            expect(content_type.fields.first.name).to eq new_field_name
          end
        end

        it 'updates content_type deleting existing field' do
          vcr('content_type/update_remove_field') do
            content_type = subject.find(content_type_id)
            field = content_type.fields.first
            content_type.update(fields: [field])
            expect(content_type.fields.size).to eq 1
          end
        end

        it 'update with multiple locales' do
          vcr('content_type/entry/update_only_with_localized_fields') do
            space = client.spaces.find('v2umtz8ths9v')
            client.content_types(space.id, 'master').all # warmup cache

            entry = client.entries(space.id, 'master').find('2dEkgsQRnSW2QuW4AMaa86')
            entry.name_with_locales = {'en-US' => 'Contentful EN up', 'de-DE' => 'Contentful DE up', 'pl-PL' => 'Contentful PL up'}
            entry.description_with_locales = {'en-US' => 'Description EN up', 'de-DE' => 'Description DE up', 'pl-PL' => 'Description PL up'}
            entry.save
            expect(entry).to be_kind_of Contentful::Management::Entry
          end
        end

      end

      describe '#save' do
        it 'updated content type' do
          vcr('content_type/save_updated') do
            content_type = subject.find(content_type_id)
            content_type.name = 'NewName'
            content_type.save
            expect(content_type).to be_kind_of Contentful::Management::ContentType
            expect(content_type.name).to eq 'NewName'
          end
        end

        it 'with new field' do
          vcr('content_type/save_with_added_field') do
            content_type = subject.find('2tDzYAg5MM6sIkwsOmM0Kc')
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
            space = client.spaces.find(space_id)
            field = Contentful::Management::Field.new
            field.id = 'my_text_field'
            field.name = 'My Text Field'
            field.type = 'Text'

            content_type = client.content_types(space.id, 'master').create(
              name: 'Post title',
              fields: [field]
            )
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
            content_type = subject.find(content_type_id)
            content_type.fields.create(id: field_id, name: 'Eye color', type: field_type)
            expect(content_type.fields.size).to eq 12
          end
        end
        it 'creates new Link field with additional parameters' do
          vcr('content_type/fields/create_with_params') do
            content_type = subject.find('qw3F2rn3FeoOiceqAiCSC')
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
            content_type = subject.find('6xzrdCr33OMAeIYUgs6UKi')
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
            content_type = subject.find('5DSpuKrl04eMAGQoQckeIq')
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
            content_type = subject.find(content_type_id)
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
            content_type = subject.find(content_type_id)
            content_type.fields.destroy('blog_title')
            expect(content_type.fields.size).to eq 10
          end
        end
      end

      describe '#entries.create' do
        it 'with Text field' do
          vcr('content_type/entry/create') do
            content_type = subject.find(content_type_id)
            entry = content_type.entries.create(name: 'Piotrek')
            expect(entry).to be_kind_of Contentful::Management::Entry
            expect(entry.fields[:name]).to eq 'Piotrek'
          end
        end

        it 'with entry' do
          vcr('content_type/entry/create_with_entries') do
            entry_en = client.entries(space_id, 'master').find('Qa8TW5nPWgiU4MA6AGYgq')
            content_type = subject.find('6xzrdCr33OMAeIYUgs6UKi')
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
              content_type = subject.find('4EnwylPOikyMGUIy8uQgQY')
              entry = content_type.entries.new
              entry.post_title_with_locales = {'en-US' => 'Company logo', 'pl' => 'Firmowe logo'}
              entry.post_body_with_locales = {'en-US' => 'Story about Contentful...', 'pl' => 'Historia o Contentful...'}
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
              content_type = subject.find('4esHTHIVgc0uWkiwGwOsa6')
              entry = content_type.entries.new
              entry.car_mark_with_locales = {'en-US' => 'Mercedes Benz', 'pl' => 'Mercedes'}
              entry.car_city_plate_with_locales = {'en-US' => 'en', 'pl' => 'bia'}
              entry.car_capacity_with_locales = {'en-US' => 2.5, 'pl' => 2.5}
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
              space = client.spaces.find(space_id)

              entry_en = client.entries(space.id, 'master').find('664EPJ6zHqAeMO6O0mGggU')
              entry_pl = client.entries(space.id, 'master').find('664EPJ6zHqAeMO6O0mGggU')

              content_type = client.content_types(space.id, 'master').find('6xzrdCr33OMAeIYUgs6UKi')
              entry = content_type.entries.new
              entry.blog_name_with_locales = {'en-US' => 'Contentful en', 'pl' => 'Contentful pl'}
              entry.blog_entries_with_locales = {'en-US' => [entry_en, entry_en], 'pl' => [entry_pl, entry_pl]}
              entry.blog_entry_with_locales = {'en-US' => entry_en, 'pl' => entry_pl}
              entry.save
              expect(entry.blog_name).to eq 'Contentful en'
            end
          end

          it 'with assets' do
            vcr('content_type/entry/create_with_entries_for_multiple_locales') do
              space = client.spaces.find(space_id)

              entry_en = client.entries(space.id, 'master').find('664EPJ6zHqAeMO6O0mGggU')
              entry_pl = client.entries(space.id, 'master').find('664EPJ6zHqAeMO6O0mGggU')

              content_type = client.content_types(space.id, 'master').find('6xzrdCr33OMAeIYUgs6UKi')
              entry = content_type.entries.new
              entry.blog_name_with_locales = {'en-US' => 'Contentful en', 'pl' => 'Contentful pl'}
              entry.blog_entries_with_locales = {'en-US' => [entry_en, entry_en], 'pl' => [entry_pl, entry_pl]}
              entry.blog_entry_with_locales = {'en-US' => entry_en, 'pl' => entry_pl}
              entry.save
              expect(entry.blog_name).to eq 'Contentful en'
            end
          end

          context 'only to unlocalized fields' do
            it 'return entry with valid parameters' do
              vcr('content_type/entry/create_only_with_localized_fields') do
                content_type = described_class.find(client, 'v2umtz8ths9v', 'master', 'category_content_type')
                entry = content_type.entries.new
                entry.name_with_locales = {'en-US' => 'Contentful EN', 'de-DE' => 'Contentful DE', 'pl-PL' => 'Contentful PL'}
                entry.description_with_locales = {'en-US' => 'Description EN', 'de-DE' => 'Description DE', 'pl-PL' => 'Description PL'}
                entry.save
                expect(entry).to be_kind_of Contentful::Management::Entry
              end
            end
          end
        end
        context 'to single locale' do
          context 'only to unlocalized fields' do
            it 'return entry with valid parameters' do
              vcr('content_type/entry/create_to_single_locale_only_with_localized_fields') do
                content_type = described_class.find(client, 'v2umtz8ths9v', 'master', 'category_content_type')
                entry = content_type.entries.new
                entry.name = 'Some testing EN name'
                entry.description = ' some testing EN description '
                entry.locale = 'de-DE'
                entry.name = 'Some testing DE name'
                entry.description = ' some testing DE description'
                entry.save
                expect(entry).to be_kind_of Contentful::Management::Entry
              end
            end
          end
        end
      end

      describe '#entries.all' do
        let(:space_id) { '9lxkhjnp8gyx' }
        it 'returns entries' do
          vcr('content_type/entry/all') do
            space = client.spaces.find(space_id)
            content_type = client.content_types(space.id, 'master').find('category_content_type')
            entries = content_type.entries.all
            expect(entries).to be_kind_of Contentful::Management::Array
            expect(entries.size).to eq 2
            expect(entries.first).to be_kind_of Contentful::Management::Entry
            expect(entries.first.sys[:contentType].id).to eq 'category_content_type'
          end
        end
      end

      describe '#reload' do
        let(:space_id) { 'bfsvtul0c41g' }
        it 'update the current version of the object to the version on the system' do
          vcr('content_type/reload') do
            content_type = described_class.find(client, space_id, 'master', 'category_content_type')
            content_type.sys[:version] = 999
            update_ct = content_type.update(name: 'Updated content type name')
            expect(update_ct).to be_kind_of Contentful::Management::Conflict
            content_type.reload
            update_ct = content_type.update(name: 'Updated content type name')
            expect(update_ct).to be_kind_of Contentful::Management::ContentType
            expect(update_ct.name).to eq 'Updated content type name'
          end
        end
      end


      describe '#validations' do
        let(:space) { client.spaces.find('v2umtz8ths9v') }
        let(:content_type) { client.content_types(space.id, 'master').find('category_content_type') }

        it "adds 'in validation' to a new field" do
          vcr('content_type/validation/in') do
            validation_in = Contentful::Management::Validation.new
            validation_in.in = ['foo', 'bar', 'baz']
            content_type.fields.create(id: 'valid', name: 'Valid', type: 'Text', validations: [validation_in])
            expect(content_type).to be_kind_of Contentful::Management::ContentType
            expect(content_type.fields.last.validations.first.properties[:in]).to eq %w( foo bar baz)
          end
        end
        it "changes 'in validation' on an existing field" do
          vcr('content_type/validation/in_update') do
            validation_in = Contentful::Management::Validation.new
            validation_in.in = ['foo', 'bar']
            content_type.fields.create(id: 'valid', name: 'Valid', type: 'Text', validations: [validation_in])
            expect(content_type).to be_kind_of Contentful::Management::ContentType
            expect(content_type.fields[2].validations.first.properties[:in]).to eq %w( foo bar )
          end
        end
        it 'adds new validation on an existing field' do
          vcr('content_type/validation/in_add') do
            validation_size = Contentful::Management::Validation.new
            validation_size.size = {min: 2, max: 10}

            content_type.fields.create(id: 'valid', name: 'Valid', type: 'Text', validations: [validation_size])
            expect(content_type).to be_kind_of Contentful::Management::ContentType
            expect(content_type.fields.last.validations.first.properties[:in]).to eq %w( foo bar baz)
            expect(content_type.fields.last.validations.last.properties[:size]['min']).to eq 2
          end
        end
        context 'size' do
          it 'adds `size` validation to field' do
            vcr('content_type/validation/size') do
              validation_size = Contentful::Management::Validation.new
              validation_size.size = {min: 10, max: 15}
              content_type.fields.create(id: 'valid', name: 'Valid', type: 'Text', validations: [validation_size])
              expect(content_type.fields[2].validations.last.properties[:size]['min']).to eq 10
              expect(content_type.fields[2].validations.last.properties[:size]['max']).to eq 15
              expect(content_type.fields[2].validations.last.type).to be :size
            end
          end
        end
        context 'range' do
          it 'adds `range` validation to field' do
            vcr('content_type/validation/range') do
              content_type = client.content_types(space.id, 'master').find('1JrDv4JJsYuY4KGEEgAsQU')

              validation_range = Contentful::Management::Validation.new
              validation_range.range = {min: 30, max: 100}
              content_type.fields.create(id: 'number', name: 'Number', type: 'Number', validations: [validation_range])
              expect(content_type.fields.first.validations.first.properties[:range]['min']).to eq 30
              expect(content_type.fields.first.validations.first.properties[:range]['max']).to eq 100
              expect(content_type.fields.first.validations.first.type).to be :range
            end
          end
          it 'change `range` validation to existing field' do
            vcr('content_type/validation/range_update') do
              content_type = client.content_types(space.id, 'master').find('1JrDv4JJsYuY4KGEEgAsQU')

              validation_range = Contentful::Management::Validation.new
              validation_range.range = {min: 50, max: 200}
              content_type.fields.create(id: 'number', name: 'Number', type: 'Number', validations: [validation_range])
              expect(content_type.fields.first.validations.first.properties[:range]['min']).to eq 50
              expect(content_type.fields.first.validations.first.properties[:range]['max']).to eq 200
            end
          end
        end
        context 'present' do
          it 'adds `present` validation to field' do
            vcr('content_type/validation/present') do
              content_type = client.content_types(space.id, 'master').find('1JrDv4JJsYuY4KGEEgAsQU')
              validation_present = Contentful::Management::Validation.new
              validation_present.present = true
              content_type.fields.create(id: 'present', name: 'Present', type: 'Text', validations: [validation_present])
              expect(content_type.fields.last.validations.last.properties[:present]).to be_truthy
              expect(content_type.fields.last.validations.last.type).to be :present
            end
          end
        end
        context 'regexp' do
          it 'adds `regexp` validation to field' do
            vcr('content_type/validation/regexp') do
              content_type = client.content_types(space.id, 'master').find('1JrDv4JJsYuY4KGEEgAsQU')
              validation_regexp = Contentful::Management::Validation.new
              validation_regexp.regexp = {pattern: '^such', flags: 'im'}
              content_type.fields.create(id: 'text', name: 'Text', type: 'Text', validations: [validation_regexp])
              expect(content_type.fields.last.validations.first.properties[:regexp]['pattern']).to eq '^such'
              expect(content_type.fields.last.validations.first.properties[:regexp]['flags']).to eq 'im'
              expect(content_type.fields.last.validations.first.type).to eq :regexp
            end
          end
        end
        context 'linkContentType' do
          it 'adds `linkContentType` validation to field' do
            vcr('content_type/validation/link_content_type') do
              content_type = client.content_types(space.id, 'master').find('1JrDv4JJsYuY4KGEEgAsQU')
              validation_link_content_type = Contentful::Management::Validation.new
              validation_link_content_type.link_content_type = ['post_content_type']
              content_type.fields.create(id: 'entries', validations: [validation_link_content_type])
              expect(content_type.fields[1].validations.first.properties[:linkContentType]).to eq %w( post_content_type )
              expect(content_type.fields[1].validations.first.type).to be :linkContentType
            end
          end
        end
        context 'linkMimetypeGroup' do
          it 'adds `linkMimetypeGroup` validation to field' do
            vcr('content_type/validation/link_mimetype_group') do
              content_type = client.content_types(space.id, 'master').find('1JrDv4JJsYuY4KGEEgAsQU')
              validation_link_mimetype_group = Contentful::Management::Validation.new
              validation_link_mimetype_group.link_mimetype_group = 'image'
              content_type.fields.create(id: 'entries', validations: [validation_link_mimetype_group])
              expect(content_type.fields[1].validations.first.properties[:linkMimetypeGroup]).to eq 'image'
              expect(content_type.fields[1].validations.first.type).to be :linkMimetypeGroup
            end
          end
        end
        context 'linkField' do
          it 'adds `linkField` validation to field' do
            vcr('content_type/validation/link_field') do
              content_type = client.content_types(space.id, 'master').find('1JrDv4JJsYuY4KGEEgAsQU')
              validation_link_mimetype_group = Contentful::Management::Validation.new
              validation_link_mimetype_group.link_field = true
              content_type.fields.create(id: 'link_field', validations: [validation_link_mimetype_group])
              expect(content_type.fields.last.validations.first.properties[:linkField]).to be_truthy
              expect(content_type.fields.last.validations.first.type).to be :linkField
            end
          end
        end
        context 'unique' do
          let(:space) { client.spaces.find('iig6ari2cj2t') }
          it 'adds `unique` validation to field' do
            vcr('content_type/validation/unique') do
              content_type = client.content_types(space.id, 'master').find('1JrDv4JJsYuY4KGEEgAsQU')
              validation_unique = Contentful::Management::Validation.new
              validation_unique.unique = true
              content_type.fields.create(id: 'symbol', name: 'Slug', type: 'Symbol', validations: [validation_unique])
              expect(content_type.fields.last.validations.first.properties[:unique]).to be_truthy
              expect(content_type.fields.last.validations.first.type).to be :unique
            end
          end
        end

        context 'add multiple validations' do
          it 'create field with multiple validations' do
            vcr('content_type/validation/multiple_add') do
              content_type = client.content_types(space.id, 'master').find('1JrDv4JJsYuY4KGEEgAsQU')
              validation_in = Contentful::Management::Validation.new
              validation_in.in = %w( foo bar baz)
              validation_regexp = Contentful::Management::Validation.new
              validation_regexp.regexp = {pattern: '^such', flags: 'im'}

              content_type.fields.create(id: 'multi', name: 'Multi Validation', type: 'Text', validations: [validation_in, validation_regexp])
              expect(content_type.fields.last.validations.first.properties[:in]).to eq %w( foo bar baz)
              expect(content_type.fields.last.validations.last.properties[:regexp]['pattern']).to eq '^such'
            end
          end
        end
      end

      describe 'create fields with array type' do
        it 'creates new content type with fields' do
          vcr('content_type/fields/create_array_types') do

            space = client.spaces.find('2jtuu7nex6e6')

            items = Contentful::Management::Field.new
            items.type = 'Link'
            items.link_type = 'Entry'

            field = Contentful::Management::Field.new
            field.id = 'entries'
            field.name = 'Entries'
            field.type = 'Array'
            field.items = items

            content_type = client.content_types(space.id, 'master').new
            content_type.space = space
            content_type.name = 'Testing Content Types'
            content_type.fields = [field]
            content_type.save

            content_type.fields.create(id: 'Entries_two', name: 'Entries Two', type: 'Array', items: items)
            first_field = content_type.fields.first
            second_field = content_type.fields.last
            expect(content_type).to be_kind_of Contentful::Management::ContentType
            expect(first_field).to be_kind_of Contentful::Management::Field
            expect(second_field).to be_kind_of Contentful::Management::Field
            expect(first_field.type).to eq 'Array'
            expect(first_field.items.link_type).to eq 'Entry'
            expect(second_field.type).to eq 'Array'
            expect(second_field.items.link_type).to eq 'Entry'
          end
        end
      end

      describe 'issues' do
        it 'content types should be valid on creation - #79' do
          vcr('content_type/issue_79') {
            space = client.spaces.find('ngtgiva4wofg')

            field = Contentful::Management::Field.new
            field.id = 'name'
            field.name = 'name'
            field.type = 'Symbol'

            content_type = client.content_types(space.id, 'master').new
            content_type.space = space
            content_type.id = 'isssue_79_ct'
            content_type.name = 'Issue 79 CT'
            content_type.fields = [field]
            content_type.display_field = 'name'

            content_type.save
            content_type.activate

            expect(content_type.sys[:version] > 0).to be_truthy
          }
        end
      end
    end
  end
end
