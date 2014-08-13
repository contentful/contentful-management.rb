# -*- encoding: utf-8 -*-
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
          vcr('entry/all') { expect(subject.all(space_id)).to be_kind_of Contentful::Management::Array }
        end
        it 'builds a Contentful::Management::Entry object' do
          vcr('entry/all') { expect(subject.all(space_id).first).to be_kind_of Contentful::Management::Entry }
        end
        it 'returns entries in context of specified content type' do
          vcr('entry/content_type_entires') do
            entries = Contentful::Management::Entry.all('9lxkhjnp8gyx', content_type_id: 'category_content_type')
            expect(entries).to be_kind_of Contentful::Management::Array
            expect(entries.first).to be_kind_of Contentful::Management::Entry
            expect(entries.first.sys[:contentType].id).to eq 'category_content_type'
          end
        end
      end

      describe '#find' do
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
            expect(result).to be_kind_of Contentful::Management::BadRequest
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
            entry2 = subject.create(content_type,
                                    name: 'EntryWithEntries',
                                    age: 20,
                                    entries: [entry_att, entry_att, entry_att])
            expect(entry2.name).to eq 'EntryWithEntries'
            expect(entry2.age).to eq 20
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
            entry = subject.create(content_type, name: 'SymbolTest', symbols: 'USD, PL, XX')
            expect(entry.name).to eq 'SymbolTest'
          end
        end
        it 'with custom id' do
          vcr('entry/create_with_custom_id') do
            entry = subject.create(content_type, id: 'custom_id', name: 'Custom Id')
            expect(entry.id).to eq 'custom_id'
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
                                  asset: asset, assets: [asset, asset, asset],
                                  entry: entry_att, entries: [entry_att, entry_att, entry_att],
                                  symbols: ['PL', 'USD', 'XX'])

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
            result.locale = 'pl'
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
    end
  end
end
