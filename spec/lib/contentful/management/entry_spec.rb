require 'spec_helper'
require 'contentful/management/space'
require 'contentful/management/client'

module Contentful
  module Management
    describe Entry do
      let(:token) { '<ACCESS_TOKEN>' }
      let(:space_id) { 'yr5m0jky5hsh' }
      let(:entry_id) { '4Rouux8SoUCKwkyCq2I0E0' }

      let!(:client) { Client.new(token) }

      subject { Contentful::Management::Entry }

      describe '.all' do
        it 'returns a Contentful::Array' do
          vcr('entry/all') { expect(subject.all('bfsvtul0c41g')).to be_kind_of Contentful::Management::Array }
        end
        it 'builds a Contentful::Management::Entry object' do
          vcr('entry/all') { expect(subject.all('bfsvtul0c41g').first).to be_kind_of Contentful::Management::Entry }
        end
        it 'returns entries in context of specified content type' do
          vcr('entry/content_type_entires') do
            entries = Contentful::Management::Entry.all('bfsvtul0c41g', content_type: 'category_content_type')
            expect(entries).to be_kind_of Contentful::Management::Array
            expect(entries.first).to be_kind_of Contentful::Management::Entry
            expect(entries.first.sys[:contentType].id).to eq 'category_content_type'
          end
        end
        it 'return limited number of entries with next_page' do
          vcr('entry/limited_entries') do
            entries = Contentful::Management::Entry.all('bfsvtul0c41g', limit: 20, skip: 2)
            expect(entries).to be_kind_of Contentful::Management::Array
            expect(entries.limit).to eq 20
            expect(entries.skip).to eq 2
            entries.next_page
          end
        end
      end

      describe '#find' do
        it 'returns null as nil on empty Symbols' do
          vcr('entry/find-with-null-symbols') do
            space = Contentful::Management::Space.find space_id
            entry = space.entries.find(entry_id)
            expect(entry.fields[:videoid]).to_not be_kind_of(String)
            expect(entry.fields[:videoid]).to be_nil
          end
        end

        it 'returns a Contentful::Management::Entry' do
          vcr('entry/find') { expect(subject.find(space_id, entry_id)).to be_kind_of Contentful::Management::Entry }
        end

        it 'returns the entry for a given key' do
          vcr('entry/find') do
            entry = subject.find(space_id, entry_id)
            expect(entry.id).to eql entry_id
          end
        end
        it 'returns an error when entry does not exists' do
          vcr('entry/find_not_found') do
            result = subject.find(space_id, 'not_exist')
            expect(result).to be_kind_of Contentful::Management::NotFound
          end
        end
        context 'raise_error when space not found' do
          let!(:client) { Client.new(token, raise_errors: true) }
          it 'returns an error when entry does not exists' do
            expect_vcr('entry/find_not_found') do
              subject.find(space_id, 'not_exist')
            end.to raise_error Contentful::Management::NotFound
          end
        end

        it 'returns an error when service is unavailable' do
          vcr('entry/service_unavailable') do
            result = subject.find(space_id, 'not_exist')
            expect(result).to be_kind_of Contentful::Management::ServiceUnavailable
            expect(result.message).to eq 'Service Unavailable, contenful.com API seems to be down'
          end
        end
      end

      describe '#destroy' do
        it 'returns Contentful::BadRequest error when content type is published' do
          vcr('entry/destory_published') do
            result = subject.find(space_id, '3U7JqGuVzOWIimU40mKeem').destroy
            expect(result).to be_kind_of Contentful::Management::BadRequest
            expect(result.message).to eq 'Cannot deleted published'
          end
        end
        it 'returns true when entry is not published' do
          vcr('entry/destroy') do
            result = subject.find(space_id, '3U7JqGuVzOWIimU40mKeem').destroy
            expect(result).to eq true
          end
        end
      end

      describe '#unpublish' do
        it 'unpublish the entry' do
          vcr('entry/unpublish') do
            entry = subject.find(space_id, entry_id)
            initial_version = entry.sys[:version]
            entry.unpublish
            expect(entry).to be_kind_of Contentful::Management::Entry
            expect(entry.sys[:version]).to eql initial_version + 1
          end
        end

        it 'returns BadRequest error when already unpublished' do
          vcr('entry/unpublish_already_unpublished') do
            result = subject.find(space_id, entry_id).unpublish
            expect(result).to be_kind_of Contentful::Management::BadRequest
            expect(result.message).to eq 'Not published'
            expect(result.error[:message]).to eq 'Not published'
            expect(result.error[:url]).to eq '/yr5m0jky5hsh/entries/4Rouux8SoUCKwkyCq2I0E0/published'
            expect(result.error[:details]).to eq "{\n  \"sys\": {\n    \"type\": \"Error\",\n    \"id\": \"BadRequest\"\n  },\n  \"message\": \"Not published\"\n}\n"
          end
        end
      end

      describe '#publish' do
        it 'returns Contentful::Management::Entry' do
          vcr('entry/publish') do
            entry = subject.find(space_id, entry_id)
            initial_version = entry.sys[:version]
            entry.publish
            expect(entry).to be_kind_of Contentful::Management::Entry
            expect(entry.sys[:version]).to eql initial_version + 1
          end
        end
        it 'returns BadRequest error when already published' do
          vcr('entry/publish_already_published') do
            entry = subject.find(space_id, entry_id)
            entry.sys[:version] = -1
            result = entry.publish
            expect(result).to be_kind_of Contentful::Management::Conflict
          end
        end
      end

      describe '#published?' do
        it 'returns true if entry is published' do
          vcr('entry/published_true') do
            entry = subject.find(space_id, entry_id)
            entry.publish
            expect(entry.published?).to be_truthy
          end
        end
        it 'returns false if entry is not published' do
          vcr('entry/published_false') do
            entry = subject.find(space_id, entry_id)
            entry.unpublish
            expect(entry.published?).to be_falsey
          end
        end
      end

      describe '#unarchive' do
        it 'unarchive the entry' do
          vcr('entry/unarchive') do
            entry = subject.find(space_id, entry_id)
            initial_version = entry.sys[:version]
            entry.unarchive
            expect(entry).to be_kind_of Contentful::Management::Entry
            expect(entry.sys[:version]).to eql initial_version + 1
          end
        end
        it 'returns BadRequest error when already unpublished' do
          vcr('entry/unarchive_already_unarchived') do
            result = subject.find(space_id, entry_id).unarchive
            expect(result).to be_kind_of Contentful::Management::BadRequest
          end
        end

        it 'returns BadRequest error when already unarchived' do
          vcr('entry/unarchive_already_unarchived') do
            result = subject.find(space_id, entry_id).unarchive
            expect(result).to be_kind_of Contentful::Management::BadRequest
            expect(result.message).to eql 'Not archived'
          end
        end
      end

      describe '#archive' do
        it 'entry' do
          vcr(:'entry/archive') do
            entry = subject.find(space_id, '3U7JqGuVzOWIimU40mKeem')
            initial_version = entry.sys[:version]
            entry.archive
            expect(entry).to be_kind_of Contentful::Management::Entry
            expect(entry.sys[:version]).to eql initial_version + 1
          end
        end
        it 'returns error when archive published entry' do
          vcr('entry/archive_published') do
            entry = subject.find(space_id, entry_id).archive
            expect(entry).to be_kind_of Contentful::Management::BadRequest
            expect(entry.message).to eql 'Cannot archive published'
          end
        end
      end

      describe '#archived?' do
        it 'returns true if entry is archived' do
          vcr('entry/archived_true') do
            entry = subject.find(space_id, entry_id)
            entry.archive
            expect(entry.archived?).to be_truthy
          end
        end
        it 'returns false if entry is not archived' do
          vcr('entry/archived_false') do
            entry = subject.find(space_id, entry_id)
            entry.unarchive
            expect(entry.archived?).to be_falsey
          end
        end
      end

      describe '.create' do
        let(:content_type_id) { '5DSpuKrl04eMAGQoQckeIq' }
        let(:content_type) { Contentful::Management::ContentType.find(space_id, content_type_id) }

        it 'create with all attributes' do
          vcr('entry/create') do
            content_type = Contentful::Management::ContentType.find('ene4qtp2sh7u', '5BHZB1vi4ooq4wKcmA8e2c')
            location = Location.new.tap do |location|
              location.lat = 22.44
              location.lon = 33.33
            end
            file = Asset.find('ene4qtp2sh7u', '2oNoT3vSAs82SOIQmKe0KG')
            entry_att = Entry.find('ene4qtp2sh7u', '60zYC7nY9GcKGiCYwAs4wm')
            entry = subject.create(content_type,
                                   name: 'Test name',
                                   number: 30,
                                   float1: 1.1,
                                   boolean: true, date: '2000-07-12T11:11:00+02:00',
                                   time: '2000-07-12T11:11:00+02:00',
                                   location: location,
                                   file: file,
                                   image: file,
                                   array: %w(PL USD XX),
                                   entry: entry_att,
                                   entries: [entry_att, entry_att],
                                   object_json: {'test' => {'@type' => 'Codequest'}}
            )
            expect(entry.name).to eq 'Test name'
            expect(entry.number).to eq 30
            expect(entry.float1).to eq 1.1
            expect(entry.boolean).to eq true
            expect(entry.date.to_s).to eq '2000-07-12T11:11:00+02:00'
            expect(entry.time.to_s).to eq '2000-07-12T11:11:00+02:00'
            expect(entry.file['sys']['id']).to eq '2oNoT3vSAs82SOIQmKe0KG'
            expect(entry.image['sys']['id']).to eq '2oNoT3vSAs82SOIQmKe0KG'
            expect(entry.array).to eq %w(PL USD XX)
            expect(entry.entry['sys']['id']).to eq entry_att.id
            expect(entry.entries.first['sys']['id']).to eq entry_att.id
          end
        end
        it 'with location' do
          vcr('entry/create_with_location') do
            location = Location.new
            location.lat = 22.44
            location.lon = 33.33

            entry = subject.create(content_type, name: 'Tom Handy', age: 30, city: location)
            expect(entry).to be_kind_of Contentful::Management::Entry
            expect(entry.name).to eq 'Tom Handy'
            expect(entry.age).to eq 30
            expect(entry.city.properties[:lat]).to eq location.lat
            expect(entry.city.properties[:lon]).to eq location.lon
          end
        end

        it 'with entry' do
          vcr('entry/create_with_entry') do
            entry_att = Entry.find(space_id, '4o6ghKSmSko4i828YCYaEo')
            entry = subject.create(content_type, name: 'EntryWithEntry', age: 20, entry: entry_att)
            expect(entry.name).to eq 'EntryWithEntry'
            expect(entry.age).to eq 20
            expect(entry.fields[:entry]['sys']['id']).to eq entry_att.id
          end
        end

        it 'with entries' do
          vcr('entry/create_with_entries') do
            entry_att = Entry.find(space_id, '1d1QDYzeiyWmgqQYysae8u')
            new_entry = subject.create(content_type,
                                       name: 'EntryWithEntries',
                                       age: 20,
                                       entries: [entry_att, entry_att, entry_att])
            expect(new_entry.name).to eq 'EntryWithEntries'
            expect(new_entry.age).to eq 20
          end
        end

        it 'with asset' do
          vcr('entry/create_with_asset') do
            asset = Asset.find(space_id, 'codequest_id_test_custom')
            entry = subject.create(content_type, name: 'OneAsset', asset: asset)
            expect(entry.name).to eq 'OneAsset'
          end
        end
        it 'with assets' do
          vcr('entry/create_with_assets') do
            asset = Asset.find(space_id, 'codequest_id_test_custom')
            entry = subject.create(content_type, name: 'multiAssets', assets: [asset, asset, asset])
            expect(entry.name).to eq 'multiAssets'
          end
        end
        it 'with symbols' do
          vcr('entry/create_with_symbols') do
            entry = subject.create(content_type, name: 'SymbolTest', symbols: %w(PL USD XX))
            expect(entry.name).to eq 'SymbolTest'
            expect(entry.symbols).to eq %w(USD PL XX)
          end
        end
        it 'with custom id' do
          vcr('entry/create_with_custom_id') do
            entry = subject.create(content_type, id: 'custom_id', name: 'Custom Id')
            expect(entry.id).to eq 'custom_id'
          end
        end
        it 'to specified locale' do
          vcr('entry/create_with_specified_locale') do
            space = Contentful::Management::Space.find('s37a4pe35l1x')
            ct = space.content_types.find('category_content_type')
            entry = ct.entries.create(name: 'Create test', description: 'Test - create entry with specified locale.', locale: 'pl-PL')
            expect(entry.name).to eq 'Create test'
          end
        end

        it 'too many requests' do
          vcr('entry/too_many_requests') do
            space = Contentful::Management::Space.find('286arvy86ry9')
            invalid_entry = space.entries.find('1YNepnMpXGiMWikaKC4GG0')
            ct = space.content_types.find('5lIEiXrCIoKoIKaSW2C8aa')
            entry = ct.entries.create(name: 'Create test', entry: invalid_entry)
            publish = entry.publish
            expect(publish).to be_a RateLimitExceeded
            expect(publish.error[:message]).to eq 'You have exceeded the rate limit of the Organization this Space belongs to by making too many API requests within a short timespan. Please wait a moment before trying the request again.'
          end
        end

        it 'with just an id' do
          vcr('entry/create_with_just_id') do
            space = Contentful::Management::Space.find('bbukbffokvih')
            entry = space.content_types.all.first.entries.create({'id' => 'yol'})
            entry.save
            expect(entry).to be_a Contentful::Management::Entry
          end
        end
      end

      describe '#update' do
        let(:entry_id) { '1I3qWOiP8k2WWYCogKy88S' }
        it 'update entry' do
          vcr('entry/update') do
            asset = Asset.find(space_id, 'codequest_id_test_custom_id')
            entry_att = Entry.find(space_id, '1d1QDYzeiyWmgqQYysae8u')
            entry = Contentful::Management::Entry.find(space_id, '4o6ghKSmSko4i828YCYaEo')

            location = Location.new
            location.lat = 22.44
            location.lon = 33.33

            result = entry.update(name: 'Tom Handy', age: 20, birthday: '2000-07-12T11:11:00+02:00',
                                  city: location,
                                  bool: false,
                                  asset: asset,
                                  assets: [asset, asset, asset],
                                  entry: entry_att,
                                  entries: [entry_att, entry_att, entry_att],
                                  symbols: %w(PL USD XX))

            expect(result).to be_kind_of Contentful::Management::Entry

            expect(result.fields[:name]).to eq 'Tom Handy'
            expect(result.fields[:age]).to eq 20
            expect(result.fields[:bool]).to eq false
            expect(result.fields[:asset]['sys']['id']).to eq asset.id
            expect(result.fields[:entry]['sys']['id']).to eq entry_att.id
            expect(result.fields[:entries].first['sys']['id']).to eq entry_att.id
          end
        end

        it 'update entry for custom locale' do
          vcr('entry/update_with_custom_locale') do
            entry = Contentful::Management::Entry.find(space_id, '3U7JqGuVzOWIimU40mKeem')
            entry.locale = 'pl'
            result = entry.update(name: 'testName', bool: true)
            expect(result).to be_kind_of Contentful::Management::Entry
            expect(result.fields[:name]).to eq 'testName'
            expect(result.fields[:bool]).to eq true
          end
        end

        it 'return Error when update not localized field' do
          vcr('entry/update_unlocalized_field') do
            asset = Asset.find(space_id, 'codequest_id_test_custom_id')

            location = Location.new
            location.lat = 22.44
            location.lon = 33.33
            entry = Contentful::Management::Entry.find(space_id, '3U7JqGuVzOWIimU40mKeem')
            entry.locale = 'pl'
            result = entry.update(name: 'DoestMatter', bool: false, city: location, asset: asset)
            expect(result).to be_kind_of Contentful::Management::Error
          end
        end

        it 'can update boolean fields to `false`' do
          vcr('entry/update_bool_field') do
            space = Contentful::Management::Space.find('fujuvqn6zcl1')
            content_type = space.content_types.find('1kUEViTN4EmGiEaaeC6ouY')

            q = content_type.entries.new
            q.name_with_locales = {'en-US' => 'Hello World'}
            q.yolo_with_locales = {'en-US' => false}
            expected = q.fields
            q.save

            p = space.entries.find(q.id)
            expect(p.fields).to match(expected)
          end
        end
      end

      describe '#save' do
        it 'save updated' do
          vcr('entry/save_update') do
            entry = Contentful::Management::Entry.find(space_id, '664EPJ6zHqAeMO6O0mGggU')
            entry.fields[:carMark] = 'Merc'
            entry.save
            expect(entry).to be_kind_of Contentful::Management::Entry
            expect(entry.fields[:carMark]).to eq 'Merc'
          end
        end
      end

      describe '#reload' do
        let(:space_id) { 'bfsvtul0c41g' }
        it 'update the current version of the object to the version on the system' do
          vcr('entry/reload') do
            space = Contentful::Management::Space.find(space_id)
            entry = space.entries.find('2arjcjtY7ucC4AGeIOIkok')
            entry.sys[:version] = 999
            update_entry = entry.update(post_title: 'Updated title')
            expect(update_entry).to be_kind_of Contentful::Management::Conflict
            entry.reload
            update_entry = entry.update(post_title: 'Updated title')
            expect(update_entry).to be_kind_of Contentful::Management::Entry
            expect(update_entry.post_title).to eq 'Updated title'
          end
        end
      end

      describe 'search filters' do
        let(:space) do
          Contentful::Management::Space.find('bfsvtul0c41g')
        end
        context 'order' do
          it 'returns ordered entries by createdAt' do
            vcr('entry/search_filter/order_sys.createdAt') do
              ordered_entries = space.entries.all(order: 'sys.createdAt')
              expect(ordered_entries).to be_kind_of Contentful::Management::Array
              expect(ordered_entries.first).to be_kind_of Contentful::Management::Entry
              expect(ordered_entries.first.sys[:createdAt] < ordered_entries.to_a[4].sys[:createdAt]).to be_truthy
            end
          end

          it 'returns ordered entries by updatedAt' do
            vcr('entry/search_filter/order_sys.updatedAt') do
              ordered_entries = space.entries.all(order: 'sys.updatedAt')
              expect(ordered_entries).to be_kind_of Contentful::Management::Array
              expect(ordered_entries.first).to be_kind_of Contentful::Management::Entry
              expect(ordered_entries.first.sys[:updatedAt] < ordered_entries.to_a[4].sys[:updatedAt]).to be_truthy
            end
          end
          context 'reverse the sort-order' do
            it 'returns reverse sort of ordered entries by updatedAt' do
              vcr('entry/search_filter/reverse_order_sys.updatedAt') do
                reverse_ordered_entries = space.entries.all(order: '-sys.updatedAt')
                expect(reverse_ordered_entries).to be_kind_of Contentful::Management::Array
                expect(reverse_ordered_entries.first).to be_kind_of Contentful::Management::Entry
                expect(reverse_ordered_entries.first.sys[:updatedAt] > reverse_ordered_entries.to_a[4].sys[:updatedAt]).to be_truthy
              end
            end
          end
        end

        context 'Including linked Entries in search results' do
          it 'returns content_type Entry and include 1 level of linked Entries' do
            vcr('entry/search_filter/including_linked_entries') do
              filtered_entries = space.entries.all('sys.id' => '2Hs5BaU56oUmUIySMQQMUS', include: 2)
              expect(filtered_entries).to be_kind_of Contentful::Management::Array
              expect(filtered_entries.first).to be_kind_of Contentful::Management::Entry
            end
          end
        end

        context 'Equality and Inequality' do
          context 'equality operator' do
            it 'returns all Entries with specified ID(IDs are unique and there can only be one)' do
              vcr('entry/search_filter/equality_operator') do
                filtered_entries = space.entries.all('sys.id' => '2Hs5BaU56oUmUIySMQQMUS')
                expect(filtered_entries).to be_kind_of Contentful::Management::Array
                expect(filtered_entries.first).to be_kind_of Contentful::Management::Entry
                expect(filtered_entries.first.sys[:id]).to eq '2Hs5BaU56oUmUIySMQQMUS'
              end
            end
            it 'returns all entries by matching fields.number equal 33' do
              vcr('entry/search_filter/matching_array_fields') do
                filtered_entries = space.entries.all(content_type: 'category_content_type', 'fields.number' => 33)
                expect(filtered_entries).to be_kind_of Contentful::Management::Array
                expect(filtered_entries.first).to be_kind_of Contentful::Management::Entry
                expect(filtered_entries.size).to eq 2
              end
            end
          end
          context 'inequality operator' do
            it 'returns all entries except entry with id = 2Hs5BaU56oUmUIySMQQMUS' do
              vcr('entry/search_filter/inequality_operator') do
                filtered_entries = space.entries.all('sys.id[ne]' => '2Hs5BaU56oUmUIySMQQMUS')
                expect(filtered_entries).to be_kind_of Contentful::Management::Array
                expect(filtered_entries.first).to be_kind_of Contentful::Management::Entry
                expect(filtered_entries.map(&:id).include?('2Hs5BaU56oUmUIySMQQMUS')).to be_falsey
              end
            end
          end
        end
        context 'Inclusion and Exclusion' do
          context 'inclusion operator' do
            it 'returns entries with specified IDs' do
              vcr('entry/search_filter/inclusion_operator') do
                filtered_entries = space.entries.all('sys.id[in]' => '2Hs5BaU56oUmUIySMQQMUS,2X3X7RHVzqsKGAgIEewgaS')
                expect(filtered_entries).to be_kind_of Contentful::Management::Array
                expect(filtered_entries.first).to be_kind_of Contentful::Management::Entry
                expect(filtered_entries.map(&:id).include?('2Hs5BaU56oUmUIySMQQMUS')).to be_truthy
                expect(filtered_entries.map(&:id).include?('2X3X7RHVzqsKGAgIEewgaS')).to be_truthy
                expect(filtered_entries.size).to eq 2
              end
            end
          end
          context 'exclusion operator' do
            it 'returns all entries except with specified IDs' do
              vcr('entry/search_filter/exclusion_operator') do
                filtered_entries = space.entries.all(content_type: 'category_content_type', 'sys.id[nin]' => '2Hs5BaU56oUmUIySMQQMUS,2X3X7RHVzqsKGAgIEewgaS')
                expect(filtered_entries).to be_kind_of Contentful::Management::Array
                expect(filtered_entries.first).to be_kind_of Contentful::Management::Entry
                expect(filtered_entries.map(&:id).include?('2Hs5BaU56oUmUIySMQQMUS')).to be_falsy
                expect(filtered_entries.map(&:id).include?('2X3X7RHVzqsKGAgIEewgaS')).to be_falsy
                expect(filtered_entries.size).to eq 3
              end
            end
          end
        end
        context 'Full-text Search' do
          it 'returns all entries except with specified IDs' do
            vcr('entry/search_filter/full_search') do
              filtered_entries = space.entries.all(query: 'find me')
              expect(filtered_entries).to be_kind_of Contentful::Management::Array
              expect(filtered_entries.first).to be_kind_of Contentful::Management::Entry
              expect(filtered_entries.size).to eq 2
            end
          end
          it 'returns all entries except with specified IDs' do
            vcr('entry/search_filter/full_search_match_operator') do
              filtered_entries = space.entries.all(content_type: 'category_content_type', 'fields.description[match]' => 'find')
              expect(filtered_entries).to be_kind_of Contentful::Management::Array
              expect(filtered_entries.first).to be_kind_of Contentful::Management::Entry
              expect(filtered_entries.size).to eq 2
            end
          end
        end
        context 'Location-based search' do
          it 'returns entries closest to a specific map location and order the results by distance' do
            vcr('entry/search_filter/location_search_near_operator') do
              filtered_entries = space.entries.all('fields.location[near]' => '23.15758,53.1297098', content_type: '37TpyB8DcQkq0wkY8c4g2g')
              expect(filtered_entries).to be_kind_of Contentful::Management::Array
              expect(filtered_entries.first).to be_kind_of Contentful::Management::Entry
            end
          end

          it 'returns entries with fields.location is inside of the circle' do
            vcr('entry/search_filter/location_search_within_operator') do
              filtered_entries = space.entries.all('fields.location[within]' => '52,23,300', content_type: '37TpyB8DcQkq0wkY8c4g2g')
              expect(filtered_entries).to be_kind_of Contentful::Management::Array
              expect(filtered_entries.first).to be_kind_of Contentful::Management::Entry
            end
          end
        end

        context 'Number & Date Ranges' do
          context 'number' do
            it 'returns entries with fields.number less then 20' do
              vcr('entry/search_filter/range_operators_less') do
                filtered_entries = space.entries.all('fields.number[lte]' => '20', content_type: 'category_content_type')
                expect(filtered_entries).to be_kind_of Contentful::Management::Array
                expect(filtered_entries.first).to be_kind_of Contentful::Management::Entry
                expect(filtered_entries.size).to eq 1
              end
            end
          end
          context 'date ranges' do
            it 'returns entries have been updated since midnight August 19th 2013' do
              vcr('entry/search_filter/range_operators_greater_than_or_equal') do
                filtered_entries = space.entries.all('sys.updatedAt[gte]' => '2014-08-19T00:00:00Z')
                expect(filtered_entries).to be_kind_of Contentful::Management::Array
                expect(filtered_entries.first).to be_kind_of Contentful::Management::Entry
                expect(filtered_entries.size).to eq 11
              end
            end
          end
        end
      end

      describe 'handling of localized values' do
        it 'retrieves localized value if it exists' do
          vcr('entry/locales/retrieve_localized') do
            space = Contentful::Management::Space.find('0agypmo1waov')
            entry = space.entries.find('5cMXsmSd5So6iggWi268eG')
            entry.locale = 'de-DE'

            expect(entry.fields.count).to eq 2
            expect(entry.fields[:yolo]).to eq 'etwas Text'
          end
        end

        it 'retrieves value of default locale if it has not been localized' do
          vcr('entry/locales/fallback_to_default_locale') do
            space = Contentful::Management::Space.find('0agypmo1waov')
            entry = space.entries.find('4epXENbO8wsaOukgqquYcI')
            entry.locale = 'de-DE'

            expect(entry.fields.count).to eq 2
            expect(entry.fields[:yolo]).to eq 'YOLO'
          end
        end

        it 'sets value for the default locale when using simple assignments' do
          vcr('entry/locales/simple_assignments_use_default_locale') do
            space = Contentful::Management::Space.find('0agypmo1waov')
            entry = space.entries.find('4epXENbO8wsaOukgqquYcI')

            entry.yolo = 'changed'

            expect(entry.fields).to match({:name => 'test2', :yolo => 'changed'})
          end
        end

        it 'sets value for the specified locales when using *_with_locales' do
          vcr('entry/locales/simple_assignments_use_specified_locale') do
            space = Contentful::Management::Space.find('0agypmo1waov')
            entry = space.entries.find('4epXENbO8wsaOukgqquYcI')

            entry.yolo_with_locales = {'de-DE' => 'changed'}
            entry.locale = 'de-DE'

            expect(entry.fields).to match({:name => 'test2', :yolo => 'changed'})
          end
        end
      end

      describe '#fields_from_attributes' do

        it 'parses all kind of fields' do

          location = Location.new.tap do |location|
            location.lat = 22.44
            location.lon = 33.33
          end

          attributes = {
              name: 'Test name',
              number: 30,
              float1: 1.1,
              boolean: true, date: '2000-07-12T11:11:00+02:00',
              time: '2000-07-12T11:11:00+02:00',
              location: location,
              image: Asset.new,
              images: [Asset.new, Asset.new],
              array: %w(PL USD XX),
              entry: Entry.new,
              entries: [Entry.new, Entry.new],
              object_json: {'test' => {'@type' => 'Codequest'}}
          }

          parsed_attributes = Entry.new.fields_from_attributes(attributes)

          expect(parsed_attributes[:name]).to match('en-US' => 'Test name')
          expect(parsed_attributes[:number]).to match('en-US' => 30)
          expect(parsed_attributes[:float1]).to match('en-US' => 1.1)
          expect(parsed_attributes[:boolean]).to match('en-US' => true)
          expect(parsed_attributes[:date]).to match('en-US' => '2000-07-12T11:11:00+02:00')
          expect(parsed_attributes[:time]).to match('en-US' => '2000-07-12T11:11:00+02:00')
          expect(parsed_attributes[:location]).to match('en-US' => {lat: 22.44, lon: 33.33})
          expect(parsed_attributes[:array]).to match('en-US' => %w(PL USD XX))
          expect(parsed_attributes[:object_json]).to match('en-US' => {'test' => {'@type' => 'Codequest'}})
          expect(parsed_attributes[:image]).to match('en-US' => {sys: {type: 'Link', linkType: 'Asset', id: nil}})
          expect(parsed_attributes[:images]).to match('en-US' => [{sys: {type: 'Link', linkType: 'Asset', id: nil}}, {sys: {type: 'Link', linkType: 'Asset', id: nil}}])
          expect(parsed_attributes[:entry]).to match('en-US' => {sys: {type: 'Link', linkType: 'Entry', id: nil}})
          expect(parsed_attributes[:entries]).to match('en-US' => [{sys: {type: 'Link', linkType: 'Entry', id: nil}}, {sys: {type: 'Link', linkType: 'Entry', id: nil}}])

        end

        it 'keepd hashes in attributes' do
          attributes = {
              entries: [{sys: {type: 'Link', linkType: 'Entry', id: nil}}, {sys: {type: 'Link', linkType: 'Entry', id: nil}}]
          }

          parsed_attributes = Entry.new.fields_from_attributes(attributes)

          expect(parsed_attributes[:entries]).to match('en-US' => [{sys: {type: 'Link', linkType: 'Entry', id: nil}}, {sys: {type: 'Link', linkType: 'Entry', id: nil}}])
        end
      end

      describe 'issues' do
        describe 'handles multiple locales even when they are not all defined for the default locale - #70' do
          it 'merges all present locales' do
            vcr('entry/issue_70') {
              space = Contentful::Management::Space.find('9sh5dtmfyzhj')

              entry_non_default_locale = space.entries.find('1PdCkb5maYgqsSUCOweseM')

              expect(entry_non_default_locale.name_with_locales).to match({"de-DE" => nil, "es" => "Futbolista"})
              expect(entry_non_default_locale.non_localized_with_locales).to match({"de-DE" => "baz", "es" => nil})

              entry_with_all_locales = space.entries.find('1QKkNRf9AEW2wqwWowgscs')

              expect(entry_with_all_locales.name_with_locales).to match({"de-DE" => "Junge", "en-US" => "Boy", "es" => "Chico"})
              expect(entry_with_all_locales.non_localized_with_locales).to match({"de-DE" => "foobar", "en-US" => nil, "es" => nil})
            }
          end

          it 'can save with multiple locales assigned - Issues/#73' do
            vcr('entry/issue_73') {
              begin
                client.configuration[:default_locale] = 'en-GB'
                content_type = Contentful::Management::ContentType.find('u2viwgfeal0o', 'someType')
                new_entry = content_type.entries.create(id: 'hello-world')

                new_entry.name = 'Hello World!'
                new_entry.locale = 'en-GB'
                new_entry.value_with_locales = {'en-GB'=>'hello world', 'es-ES'=>'hola mundo'}

                res = new_entry.save

                expect(res.respond_to?(:error)).to be_falsey
                expect(res.is_a?(Contentful::Management::DynamicEntry)).to be_truthy
                expect(res.value_with_locales).to match('en-GB' => 'hello world', 'es-ES' => 'hola mundo')
              ensure
                new_entry.destroy
              end
            }
          end
        end
      end
    end
  end
end
