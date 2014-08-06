# -*- encoding: utf-8 -*-
require 'spec_helper'
require 'contentful/management/space'
require 'contentful/management/client'
require 'contentful/management/asset'

module Contentful
  module Management
    describe Asset do
      let(:token) { '<ACCESS_TOKEN>' }
      let(:space_id) { 'yr5m0jky5hsh' }

      let(:asset_id) { '3PYa73pXXiAmKqm8eu4qOS' }
      let(:asset_id_2) { '5FDqplZoruAUGmiSa02asE' }

      let!(:client) { Client.new(token) }

      subject { Contentful::Management::Asset }

      describe '.all' do
        it 'returns a Contentful::Array' do
          vcr('asset/all') { expect(subject.all(space_id)).to be_kind_of Contentful::Management::Array }
        end
        it 'builds a Contentful::Management::Asset object' do
          vcr('asset/all') { expect(subject.all(space_id).first).to be_kind_of Contentful::Management::Asset }
        end
      end

      describe '#find' do
        it 'returns a Contentful::Management::Asset' do
          vcr('asset/find') { expect(subject.find(space_id, asset_id)).to be_kind_of Contentful::Management::Asset }
        end
        it 'returns the asset for a given key' do
          vcr('asset/find') do
            asset = subject.find(space_id, asset_id)
            expect(asset.id).to eql asset_id
          end
        end
        it 'returns an error when content_type does not exists' do
          vcr('asset/find_not_found') do
            result = subject.find(space_id, 'not_exist')
            expect(result).to be_kind_of Contentful::Management::NotFound
          end
        end
      end

      describe '#destroy' do
        it 'returns Contentful::BadRequest error when content type is published' do
          vcr('asset/destroy_published') do
            result = subject.find(space_id, 'r7o2iuDeSc4UmioOuoKq6').destroy
            expect(result).to be_kind_of Contentful::Management::BadRequest
            expect(result.message).to eq 'Cannot deleted published'
          end
        end
        it 'returns true when asset is not published' do
          vcr('asset/destroy') do
            result = subject.find(space_id, 'r7o2iuDeSc4UmioOuoKq6').destroy
            expect(result).to eq true
          end
        end
      end

      describe '#unpublish' do
        it 'unpublish' do
          vcr('asset/unpublish') do
            asset = subject.find(space_id, asset_id_2)
            initial_version = asset.sys[:version]
            asset.unpublish
            expect(asset).to be_kind_of Contentful::Management::Asset
            expect(asset.sys[:version]).to eql initial_version + 1
          end
        end

        it 'returns BadRequest error when already unpublished' do
          vcr('asset/unpublish_already_unpublished') do
            result = subject.find(space_id, asset_id_2).unpublish
            expect(result).to be_kind_of Contentful::Management::BadRequest
            expect(result.message).to eq 'Not published'
          end
        end
      end

      describe '#publish' do
        it ' after create' do
          vcr('asset/publish_after_create') do
            file1 = Contentful::Management::File.new
            file1.properties[:contentType] = 'image/jpeg'
            file1.properties[:fileName] = 'pic1.jpg'
            file1.properties[:upload] = 'https://upload.wikimedia.org/wikipedia/commons/c/c7/Gasometer_Berlin_Sch%C3%B6neberg_2011.jpg'
            asset = Contentful::Management::Asset.create(space_id,
                                                         title: 'titlebyCreateAPI',
                                                         description: 'descByAPI',
                                                         file: file1)
            expect(asset).to be_kind_of Contentful::Management::Asset
            asset.publish
            expect(asset.published?).to be_truthy
          end
        end
        it 'returns Contentful::Management::Asset' do
          vcr('asset/publish') do
            asset = subject.find(space_id, asset_id_2)
            initial_version = asset.sys[:version]
            asset.publish
            expect(asset).to be_kind_of Contentful::Management::Asset
            expect(asset.sys[:version]).to eql initial_version + 1
          end
        end
        it 'returns BadRequest error when already published' do
          vcr('asset/publish_already_published') do
            asset = subject.find(space_id, asset_id_2)
            asset.sys[:version] = -1
            result = asset.publish
            expect(result).to be_kind_of Contentful::Management::BadRequest
          end
        end
      end

      describe '#published?' do
        it 'returns true if asset is published' do
          vcr('asset/published_true') do
            asset = subject.find(space_id, asset_id)
            asset.publish
            expect(asset.published?).to be_truthy
          end
        end
        it 'returns false if asset is not published' do
          vcr('asset/published_false') do
            asset = subject.find(space_id, asset_id)
            asset.unpublish
            expect(asset.published?).to be_falsey
          end
        end
      end

      describe '#unarchive' do
        it 'unarchive the asset' do
          vcr('asset/unarchive') do
            asset = subject.find(space_id, asset_id_2)
            initial_version = asset.sys[:version]
            asset.unarchive
            expect(asset).to be_kind_of Contentful::Management::Asset
            expect(asset.sys[:version]).to eql initial_version + 1
          end
        end

        it 'returns BadRequest error when already unpublished' do
          vcr('asset/unarchive_already_unarchived') do
            result = subject.find(space_id, asset_id_2).unarchive
            expect(result).to be_kind_of Contentful::Management::BadRequest
          end
        end
      end

      describe '#archive' do
        it 'returns error when archive published asset' do
          vcr('asset/archive_published') do
            asset = subject.find(space_id, asset_id_2).archive
            expect(asset).to be_kind_of Contentful::Management::BadRequest
          end
        end

        it ' archive unpublished asset' do
          vcr('asset/archive') do
            asset = subject.find(space_id, asset_id_2)
            initial_version = asset.sys[:version]
            asset.archive
            expect(asset).to be_kind_of Contentful::Management::Asset
            expect(asset.sys[:version]).to eql initial_version + 1
          end
        end

        it 'returns BadRequest error when already unpublished' do
          vcr('asset/unarchive_already_unarchive') do
            result = subject.find(space_id, asset_id_2).unarchive
            expect(result).to be_kind_of Contentful::Management::BadRequest
          end
        end
      end

      describe '#archived?' do
        it 'returns true if asset is archive' do
          vcr('asset/archived_true') do
            asset = subject.find(space_id, asset_id_2)
            asset.archive
            expect(asset.archived?).to be_truthy
          end
        end
        it 'returns false if asset is not archive' do
          vcr('asset/archived_false') do
            asset = subject.find(space_id, asset_id_2)
            asset.unarchive
            expect(asset.archived?).to be_falsey
          end
        end
      end

      describe '#locale' do
        it 'returns default locale' do
          vcr('asset/locale') do
            asset = subject.find(space_id, asset_id_2)
            expect(asset.locale).to eq asset.default_locale
            expect(asset.title).to eq 'titlebyCreateAPI'
            expect(asset.description).to eq 'descByAPI'
          end
        end

        it 'set locale to given asset' do
          vcr('asset/set_locale') do
            asset = subject.find(space_id, asset_id_2)
            asset.locale = 'pl-Pl'
            expect(asset.sys[:locale]).to eq 'pl-Pl'
          end
        end
      end

      describe '.create' do
        it 'creates asset ' do
          vcr('asset/create') do

            file1 = Contentful::Management::File.new
            file1.properties[:contentType] = 'image/jpeg'
            file1.properties[:fileName] = 'pic1.jpg'
            file1.properties[:upload] = 'https://upload.wikimedia.org/wikipedia/commons/c/c7/Gasometer_Berlin_Sch%C3%B6neberg_2011.jpg'

            asset = Contentful::Management::Asset.create(space_id, title: 'titlebyCreateAPI', description: 'descByAPI', file: file1)
            expect(asset).to be_kind_of Contentful::Management::Asset
            expect(asset.title).to eq 'titlebyCreateAPI'
            expect(asset.description).to eq 'descByAPI'
          end
        end

        it 'creates asset with custom ID' do
          vcr('asset/create_with_custom_id') do
            file = Contentful::Management::File.new

            file.properties[:contentType] = 'image/jpeg'
            file.properties[:fileName] = 'codequest.jpg'
            file.properties[:upload] = 'http://static.goldenline.pl/firm_logo/082/firm_225106_22f37f_small.jpg'

            asset = Contentful::Management::Asset.create(space_id, id: 'codequest_id_test_custom', title: 'titlebyCreateAPI_custom_id', description: 'descByAPI_custom_id', file: file)
            expect(asset).to be_kind_of Contentful::Management::Asset
            expect(asset.id).to eq 'codequest_id_test_custom'
            expect(asset.title).to eq 'titlebyCreateAPI_custom_id'
            expect(asset.description).to eq 'descByAPI_custom_id'
          end
        end
        it 'creates asset with duplicated custom ID' do
          vcr('asset/create_with_already_used_id') do
            file = Contentful::Management::File.new

            file.properties[:contentType] = 'image/jpeg'
            file.properties[:fileName] = 'codequest.jpg'
            file.properties[:upload] = 'http://static.goldenline.pl/firm_logo/082/firm_225106_22f37f_small.jpg'

            asset = Contentful::Management::Asset.create(space_id, id: 'codequest_id_test_custom_id', title: 'titlebyCreateAPI_custom_id', description: 'descByAPI_custom_id', file: file)
            expect(asset).to be_kind_of Contentful::Management::BadRequest
          end
        end
      end

      describe '#update' do
        it 'updates asset with default locale without file' do
          vcr('asset/update_with_default_locale_without_file') do
            asset = subject.find(space_id, '4DmT2j54pWY8ocimkEU6qS')
            asset.update(title: 'Title new', description: 'Description new')
            expect(asset).to be_kind_of Contentful::Management::Asset
            expect(asset.title).to eq 'Title new'
            expect(asset.description).to eq 'Description new'
          end
        end

        it 'updates asset with default locale with file' do
          vcr('asset/update_file') do

            file = Contentful::Management::File.new
            file.properties[:contentType] = 'image/jpeg'
            file.properties[:fileName] = 'codequest.jpg'
            file.properties[:upload] = 'http://static.goldenline.pl/firm_logo/082/firm_225106_22f37f_small.jpg'

            asset = subject.find(space_id, '4DmT2j54pWY8ocimkEU6qS')
            asset.update(file: file)
            expect(asset).to be_kind_of Contentful::Management::Asset
            expect(asset.file.properties[:fileName]).to eq 'codequest.jpg'
          end
        end

        it 'updates asset to specified locale' do
          vcr('asset/update_to_specified_locale') do
            file = Contentful::Management::File.new
            file.properties[:contentType] = 'image/jpeg'
            file.properties[:fileName] = 'codequest.jpg'
            file.properties[:upload] = 'http://static.goldenline.pl/firm_logo/082/firm_225106_22f37f_small.jpg'

            asset = subject.find(space_id, 'codequest_id_test_custom_id')
            asset.locale = 'pl'

            asset.update(title: 'updateTitlePl', description: 'updateDescPl', file: file)
            expect(asset).to be_kind_of Contentful::Management::Asset
            asset.locale = 'pl'
            expect(asset.title).to eq 'updateTitlePl'
            expect(asset.description).to eq 'updateDescPl'
            expect(asset.file.properties[:fileName]).to eq 'codequest.jpg'
          end
        end
      end
      describe '#save' do
        it 'updated' do
          vcr('asset/save_update') do
            asset = Contentful::Management::Asset.find(space_id, '35Kt2tInIsoauo8sC82q04')
            asset.fields[:description] = 'Firmowe logo.'
            asset.save
            expect(asset).to be_kind_of Contentful::Management::Asset
            expect(asset.fields[:description]).to eq 'Firmowe logo.'
          end
        end
      end
      describe '#image_url' do
        it 'empty_query' do
          vcr('asset/image_url') do
            asset = Contentful::Management::Asset.find(space_id, '35Kt2tInIsoauo8sC82q04')
            asset.image_url
            expect(asset).to be_kind_of Contentful::Management::Asset
          end
        end
        it 'with_params' do
          vcr('asset/image_url') do
            asset = Contentful::Management::Asset.find(space_id, '35Kt2tInIsoauo8sC82q04')
            asset.image_url(w: 111, h: 11)
            expect(asset).to be_kind_of Contentful::Management::Asset
          end
        end
      end

    end
  end
end
