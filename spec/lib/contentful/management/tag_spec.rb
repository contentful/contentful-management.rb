require 'spec_helper'
require 'contentful/management/space'
require 'contentful/management/client'

module Contentful
  module Management
    describe Tag do
      let(:token) { ENV.fetch('CF_TEST_CMA_TOKEN', '<ACCESS_TOKEN>') }
      let(:space_id) { 'o4h6g9w3pooi' }
      let(:tag_id) { 'fooTag' }

      let!(:client) { Contentful::Management::Client.new(token) }

      subject { client.tags(space_id, 'master') }

      describe '.all' do
        it 'class method also works' do
          vcr('tag/all') { expect(Contentful::Management::Tag.all(client, 'o4h6g9w3pooi', 'master')).to be_kind_of Contentful::Management::Array }
        end
        it 'returns a Contentful::Array' do
          vcr('tag/all') { expect(described_class.all(client, 'o4h6g9w3pooi', 'master')).to be_kind_of Contentful::Management::Array }
        end
        it 'builds a Contentful::Management::Tag object' do
          vcr('tag/all') { expect(described_class.all(client, 'o4h6g9w3pooi', 'master').first).to be_kind_of Contentful::Management::Tag }
        end
      end

      describe '.find' do
        it 'class method also works' do
          vcr('tag/find') { expect(Contentful::Management::Tag.find(client, space_id, 'master', tag_id)).to be_kind_of Contentful::Management::Tag }
        end
        it 'returns a Contentful::Management::Tag' do
          vcr('tag/find') { expect(subject.find(tag_id)).to be_kind_of Contentful::Management::Tag }
        end
        it 'returns the tag for a given tag id' do
          vcr('tag/find') do
            tag = subject.find(tag_id)
            expect(tag.id).to eql tag_id
            expect(tag.name).to eql 'Foo Tag'
          end
        end
        it 'returns an error when tag does not exists' do
          vcr('tag/not_found') do
            result = subject.find('not_exist')
            expect(result).to be_kind_of Contentful::Management::NotFound
          end
        end
      end

      describe '.create' do
        it "create tag with default 'private' visibility" do
          vcr('tag/create_visibility_private') do
            tag = client.tags(space_id, 'master').create(name: 'test private', id: 'testPrivate')
            expect(tag.name).to eql 'test private'
            expect(tag.id).to eql 'testPrivate'
            expect(tag.sys[:visibility]).to eql 'private'
          end
        end

        it "create tag with 'public' visibility" do
          vcr('tag/create_visibility_public') do
            tag = client.tags(space_id, 'master').create(name: 'test public', id: 'testPublic', visibility: 'public')
            expect(tag.name).to eql 'test public'
            expect(tag.id).to eql 'testPublic'
            expect(tag.sys[:visibility]).to eql 'public'
          end
        end
      end

      describe '.update' do
        it 'updates tag name' do
          vcr('tag/update') do
            tag = subject.find(tag_id)
            tag.update(name: 'updated tag')
            expect(tag.name).to eq 'updated tag'
          end
        end
      end

      describe '#destroy' do
        it 'returns validation error when tag is referenced by another entity' do
          vcr('tag/destroy_referenced') do
            result = subject.find('icon').destroy
            message = "HTTP status code: 422 Unprocessable Entity\n"\
  "Message: Validation error\n"\
  "Details: \n"\
  "\t* Name: reference - Path: '' - Value: ''\n"\
  "Request ID: 727a53d1-e679-4654-8bec-f955da1334e9"

            expect(result).to be_kind_of Contentful::Management::Error
            expect(result.message).to eq message
          end
        end

        it 'returns true when content type is not activated' do
          vcr('tag/destroy') do
            result = subject.find('randomTag').destroy
            expect(result).to eql true
          end
        end
      end

      describe 'tag an entry' do
        it 'creates entry with tags' do
          vcr('tag/create_entry_with_tags') do
            content_type = client.content_types(space_id, 'master').find('simple')
            entry = client.entries(space_id, 'master').create(
              content_type,
              title: 'Entry title',
              _metadata: { "tags": [{ "sys": { "type": "Link", "linkType": "Tag", "id": "icon" } }] }
            )

            expect(entry._metadata[:tags].count).to eq(1)
            expect(entry._metadata[:tags].first.id).to eq('icon')
          end
        end

        it 'add tags to an entry' do
          vcr('tag/add_tag_to_entry') do
            entry = client.entries(space_id, 'master').find('28spH12WTOl0xUQeC4AL1a')
            expect(entry._metadata[:tags]).to be_empty

            result = entry.update(_metadata: { "tags": [{ "sys": { "type": "Link", "linkType": "Tag", "id": "icon" } }] })
            expect(result).to be_kind_of Contentful::Management::Entry
            expect(result._metadata[:tags].count).to eq(1)
            expect(result._metadata[:tags].first.id).to eq('icon')
          end
        end

        it 'remove tags from an entry' do
          vcr('tag/remove_tag_from_entry') do
            entry = client.entries(space_id, 'master').find('28spH12WTOl0xUQeC4AL1a')
            expect(entry._metadata[:tags]).not_to be_empty

            entry.update(_metadata: { "tags": [] })
            expect(entry._metadata[:tags]).to be_empty
          end
        end
      end

      describe 'tag an asset' do
        it 'creates asset with tags' do
          vcr('tag/create_asset_with_tags') do
            file = Contentful::Management::File.new
            file.properties[:contentType] = 'image/jpeg'
            file.properties[:fileName] = 'pic1.jpg'
            file.properties[:upload] = 'https://upload.wikimedia.org/wikipedia/commons/c/c7/Gasometer_Berlin_Sch%C3%B6neberg_2011.jpg'

            asset = client.assets(space_id, 'master').create(
              title: 'Asset title',
              file: file,
              _metadata: { "tags": [{ "sys": { "type": "Link", "linkType": "Tag", "id": "icon" } }] }
            )

            expect(asset._metadata[:tags].count).to eq(1)
            expect(asset._metadata[:tags].first.id).to eq('icon')
          end
        end

        it 'add tags to an asset' do
          vcr('tag/add_tag_to_asset') do
            environment = client.environments(space_id).find('master')
            asset = environment.assets.find('686aLBcjj1f47uFWxrepj6')
            expect(asset._metadata[:tags]).to be_empty

            result = asset.update(_metadata: { "tags": [{ "sys": { "type": "Link", "linkType": "Tag", "id": "icon" } }] })
            expect(result).to be_kind_of Contentful::Management::Asset
            expect(result._metadata[:tags].count).to eq(1)
            expect(result._metadata[:tags].first.id).to eq('icon')
          end
        end

        it 'remove tags from an asset' do
          vcr('tag/remove_tag_from_asset') do
            environment = client.environments(space_id).find('master')
            asset = environment.assets.find('686aLBcjj1f47uFWxrepj6')
            expect(asset._metadata[:tags]).not_to be_empty

            asset.update(_metadata: { "tags": [] })
            expect(asset._metadata[:tags]).to be_empty
          end
        end
      end
    end
  end
end
