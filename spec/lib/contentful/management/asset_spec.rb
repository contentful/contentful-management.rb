require 'spec_helper'
require 'contentful/management/space'
require 'contentful/management/client'
require 'contentful/management/asset'

module Contentful
  module Management
    describe Asset do
      let(:token) { '51cb89f45412ada2be4361599a96d6245e19913b6d2575eaf89dafaf99a443aa' }
      let(:space_id) { 'n6spjc167pc2' }
      let(:asset_id) { 'd42EjBLxdYiuSOyOkUyo6' }
      let(:asset_id_2) { '1730O0aAdyg66u604MyEWC' }

      let!(:client) { Client.new(token) }

      subject { Contentful::Management::Asset }

      describe '.all' do
        it 'returns a Contentful::Array' do
          vcr(:get_assets_for_space) { expect(subject.all(space_id)).to be_kind_of Contentful::Array }
        end
        it 'builds a Contentful::Management::Asset object' do
          vcr(:get_assets_for_space) { expect(subject.all(space_id).first).to be_kind_of Contentful::Management::Asset }
        end
      end

      describe '#find' do
        it 'returns a Contentful::Management::Asset' do
          vcr(:get_asset_for_space) { expect(subject.find(space_id, asset_id)).to be_kind_of Contentful::Management::Asset }
        end
        it 'returns the asset for a given key' do
          vcr(:get_asset_for_space) do
            asset = subject.find(space_id, asset_id)
            expect(asset.id).to eql asset_id
          end
        end
        it 'returns an error when content_type does not exists' do
          vcr(:get_asset_not_found_in_space) do
            result = subject.find(space_id, 'not_exist')
            expect(result).to be_kind_of Contentful::NotFound
          end
        end
      end

      describe '#destroy' do
        it 'returns Contentful::BadRequest error when content type is published' do
          vcr(:delete_asset_published) do
            result = subject.find(space_id, '4xneId8DGouekuCcQ8yKUU').destroy
            expect(result).to be_kind_of Contentful::BadRequest
            expect(result.message).to eq 'Cannot deleted published'
          end
        end
        it 'returns true when asset is not published' do
          vcr(:asset_destroy) do
            result= subject.find(space_id, '4xneId8DGouekuCcQ8yKUU').destroy
            expect(result).to eq true
          end
        end
      end

      describe '#unpublish' do
        it 'unpublish the asset' do
          vcr(:asset_unpublish) do
            asset = subject.find(space_id, asset_id_2)
            initial_version = asset.sys[:version]
            asset.unpublish
            expect(asset).to be_kind_of Contentful::Management::Asset
            expect(asset.sys[:version]).to eql initial_version + 1
          end
        end

        it 'returns BadRequest error when already unpublished' do
          vcr(:unpublish_asset_already_unpublished) do
            result = subject.find(space_id, asset_id_2).unpublish
            expect(result).to be_kind_of Contentful::BadRequest
            expect(result.message).to eq 'Not published'
          end
        end
      end

      describe '#publish' do
        it 'returns Contentful::Management::Asset' do
          vcr(:asset_publish) do
            asset = subject.find(space_id, asset_id_2)
            initial_version = asset.sys[:version]
            asset.publish
            expect(asset).to be_kind_of Contentful::Management::Asset
            expect(asset.sys[:version]).to eql initial_version + 1
          end
        end
        it 'returns BadRequest error when already published' do
          vcr(:publish_asset_already_published) do
            asset = subject.find(space_id, asset_id_2)
            asset.sys[:version] = -1
            result= asset.publish
            expect(result).to be_kind_of Contentful::BadRequest
          end
        end
      end

      describe '#published?' do
        it 'returns true if asset is publish' do
          vcr(:asset_published_true) do
            asset = subject.find(space_id, asset_id)
            asset.publish
            expect(asset.published?).to be_truthy
          end
        end
        it 'returns false if asset is not publish' do
          vcr(:asset_published_false) do
            asset = subject.find(space_id, asset_id)
            asset.unpublish
            expect(asset.published?).to be_falsey
          end
        end
      end

      describe '#unarchive' do
        it 'unarchive the asset' do
          vcr(:asset_unarchive) do
            asset = subject.find(space_id, asset_id_2)
            initial_version = asset.sys[:version]
            asset.unarchive
            expect(asset).to be_kind_of Contentful::Management::Asset
            expect(asset.sys[:version]).to eql initial_version + 1
          end
        end

        it 'returns BadRequest error when already unpublished' do
          vcr(:unarchive_asset_already_unarchived) do
            result = subject.find(space_id, asset_id_2).unarchive
            expect(result).to be_kind_of Contentful::BadRequest
          end
        end
      end

      describe '#archive' do
        it 'returns error when archive published asset' do
          vcr(:asset_archive_published) do
            asset = subject.find(space_id, asset_id_2).archive
            expect(asset).to be_kind_of Contentful::BadRequest
          end
        end

        it ' archive unpublished asset' do
          vcr(:asset_archive) do
            asset = subject.find(space_id, asset_id_2)
            initial_version = asset.sys[:version]
            asset.archive
            expect(asset).to be_kind_of Contentful::Management::Asset
            expect(asset.sys[:version]).to eql initial_version + 1
          end
        end

        it 'returns BadRequest error when already unpublished' do
          vcr(:unarchive_asset_already_unarchive) do
            result = subject.find(space_id, asset_id_2).unarchive
            expect(result).to be_kind_of Contentful::BadRequest
          end
        end
      end

      describe '#archived?' do
        it 'returns true if asset is archive' do
          vcr(:asset_archived_true) do
            asset = subject.find(space_id, asset_id_2)
            asset.archive
            expect(asset.archived?).to be_truthy
          end
        end
        it 'returns false if asset is not archive' do
          vcr(:asset_archived_false) do
            asset = subject.find(space_id, asset_id_2)
            asset.unarchive
            expect(asset.archived?).to be_falsey
          end
        end
      end

      describe '.create' do
        let(:asset_title) { ' My Asset title' }
        let(:asset_description) { 'Asset Description' }

        it 'creates asset' do
          skip 'not implemented yet'
          vcr(:asset_create) do

            asset = Contentful::Management::Asset.create(space_id, fields: fields)
            expect(asset).to be_kind_of Contentful::Management::Asset
            expect(asset.title).to eq asset_title
            expect(asset.description).to eq asset_description
          end
        end
      end

      describe '#update' do
        it 'updates asset' do
          vcr(:asset_update) do
            skip 'not implemented yet'
            fields = Contentful::Management::AssetFields.new(space_id)
            fields.title = asset_title
            fields.description = asset_description

            asset = Contentful::Management::Asset.update(space_id, fields: fields)
            expect(asset).to be_kind_of Contentful::Management::Asset
            expect(asset.name).to eq asset_title
            expect(asset.description).to eq asset_description
            expect(asset.fields.size).to eq 1
            result_field = asset.fields.first
            expect(result_field.fileName).to eq field.title
            expect(result_field.contentType).to eq field.type
          end
        end
      end

    end
  end
end