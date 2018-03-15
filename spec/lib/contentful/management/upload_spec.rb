require 'spec_helper'
require 'contentful/management/space'
require 'contentful/management/client'

module Contentful
  module Management
    describe Upload do
      let(:token) { '<ACCESS_TOKEN>' }
      let(:space_id) { 'facgnwwgj5fe' }
      let(:upload_id) { 'IUMb6WLjk9fjQ0WZfG971' }
      let(:pixel_path) { ::File.join('spec', 'fixtures', 'pixel.jpg') }
      let!(:client) { Client.new(token) }

      subject { client.uploads(space_id) }

      describe '.find' do
        it 'class method also works' do
          vcr('upload/find') {
            upload = Contentful::Management::Upload.find(client, space_id, upload_id)
            expect(upload).to be_kind_of Contentful::Management::Upload
            expect(upload.id).to eq upload_id
          }
        end
        it 'returns a Contentful::Management::Upload' do
          vcr('upload/find') {
            upload = subject.find(upload_id)
            expect(upload).to be_kind_of Contentful::Management::Upload
            expect(upload.id).to eq upload_id
          }
        end
        it 'returns upload for a given key' do
          vcr('upload/find') do
            upload = subject.find(upload_id)
            expect(upload).to be_kind_of Contentful::Management::Upload
            expect(upload.id).to eq upload_id
          end
        end
        it 'returns an error when upload does not exist' do
          vcr('upload/find_not_found') do
            result = subject.find('not_exist')
            expect(result).to be_kind_of Contentful::Management::NotFound
          end
        end
      end

      describe '.create' do
        it 'creates an upload from a ::File' do
          vcr('upload/create_file') do
            ::File.open(pixel_path, 'rb') do |f|
              upload = subject.create(f)
              expect(upload).to be_kind_of Contentful::Management::Upload
            end
          end
        end

        it 'creates an upload from a /path/to/file' do
          vcr('upload/create_path') do
            upload = subject.create(pixel_path)
            expect(upload).to be_kind_of Contentful::Management::Upload
          end
        end

        it 'an upload can be associated to an asset' do
          vcr('upload/associate_with_asset') do
            upload = subject.create(pixel_path)

            file = Contentful::Management::File.new
            file.properties[:contentType] = 'image/jpeg'
            file.properties[:fileName] = 'pixel'
            file.properties[:uploadFrom] = upload.to_link_json

            asset = client.assets(space_id, 'master').create(title: 'pixel', file: file)
            asset.process_file
            asset.reload

            expect(asset.file.url).not_to be_nil
          end
        end
      end

      describe '#destroy' do
        it 'returns true' do
          vcr('upload/destroy') do
            upload = subject.find(upload_id)
            result = upload.destroy
            expect(result).to eq true
          end
        end
      end
    end
  end
end
