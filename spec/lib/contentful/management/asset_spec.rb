require 'spec_helper'
require 'contentful/management/space'
require 'contentful/management/client'
require 'contentful/management/asset'

module Contentful
  module Management
    describe Asset do
      let(:token) { ENV.fetch('CF_TEST_CMA_TOKEN', '<ACCESS_TOKEN>') }
      let(:space_id) { 'yr5m0jky5hsh' }
      let(:asset_id) { '3PYa73pXXiAmKqm8eu4qOS' }
      let(:asset_id_2) { '5FDqplZoruAUGmiSa02asE' }

      let!(:client) { Client.new(token) }

      subject { client.assets(space_id, 'master') }

      describe '.all' do
        it 'class method also works' do
          vcr('asset/all') { expect(Contentful::Management::Asset.all(client, space_id, 'master')).to be_kind_of Contentful::Management::Array }
        end
        it 'returns a Contentful::Array' do
          vcr('asset/all') { expect(subject.all).to be_kind_of Contentful::Management::Array }
        end
        it 'builds a Contentful::Management::Asset object' do
          vcr('asset/all') { expect(subject.all.first).to be_kind_of Contentful::Management::Asset }
        end
        it 'return limited number of assets with next_page' do
          vcr('asset/limited_assets_next_page') do
            assets = described_class.all(client, 'bfsvtul0c41g', 'master', limit: 20, skip: 2)
            expect(assets).to be_kind_of Contentful::Management::Array
            expect(assets.limit).to eq 20
            expect(assets.skip).to eq 2
            assets.next_page
          end
        end
        it 'supports select operator' do
          vcr('asset/select_operator') do
            nyancat = described_class.all(client, 'cfexampleapi', 'master', 'sys.id' => 'nyancat', select: 'fields.title').first
            expect(nyancat.fields).to eq({ title: 'Nyan Cat' })
          end
        end
      end

      describe '.find' do
        it 'class method also works' do
          vcr('asset/find') { expect(Contentful::Management::Asset.find(client, space_id, 'master', asset_id)).to be_kind_of Contentful::Management::Asset }
        end
        it 'returns a Contentful::Management::Asset' do
          vcr('asset/find') { expect(subject.find(asset_id)).to be_kind_of Contentful::Management::Asset }
        end
        it 'returns the asset for a given key' do
          vcr('asset/find') do
            asset = subject.find(asset_id)
            expect(asset.id).to eql asset_id
          end
        end
        it 'returns an error when content_type does not exists' do
          vcr('asset/find_not_found') do
            result = subject.find('not_exist')
            expect(result).to be_kind_of Contentful::Management::NotFound
            message = [
              "HTTP status code: 404 Not Found",
              "Message: The resource could not be found.",
              "Details: The requested Asset could not be found. ID: not_exist."
            ].join("\n")
            expect(result.message).to eq message
          end
        end
      end

      describe '#destroy' do
        it 'returns Contentful::BadRequest error when content type is published' do
          vcr('asset/destroy_published') do
            result = subject.find('r7o2iuDeSc4UmioOuoKq6').destroy
            expect(result).to be_kind_of Contentful::Management::BadRequest
            message = [
              "HTTP status code: 400 Bad Request",
              "Message: Cannot delete published"
            ].join("\n")
            expect(result.message).to eq message
          end
        end
        it 'returns true when asset is not published' do
          vcr('asset/destroy') do
            result = subject.find('r7o2iuDeSc4UmioOuoKq6').destroy
            expect(result).to eq true
          end
        end
      end

      describe '#unpublish' do
        it 'unpublish' do
          vcr('asset/unpublish') do
            asset = subject.find(asset_id_2)
            initial_version = asset.sys[:version]
            asset.unpublish
            expect(asset).to be_kind_of Contentful::Management::Asset
            expect(asset.sys[:version]).to eql initial_version + 1
          end
        end

        it 'returns BadRequest error when already unpublished' do
          vcr('asset/unpublish_already_unpublished') do
            result = subject.find(asset_id_2).unpublish
            expect(result).to be_kind_of Contentful::Management::BadRequest
            message = [
              "HTTP status code: 400 Bad Request",
              "Message: Not published"
            ].join("\n")
            expect(result.message).to eq message
          end
        end
      end

      describe '#publish' do
        it 'returns Contentful::Management::Asset' do
          vcr('asset/publish_after_create') do
            file = Contentful::Management::File.new
            file.properties[:contentType] = 'image/jpeg'
            file.properties[:fileName] = 'pic1.jpg'
            file.properties[:upload] = 'https://upload.wikimedia.org/wikipedia/commons/c/c7/Gasometer_Berlin_Sch%C3%B6neberg_2011.jpg'

            asset = subject.create(
              title: 'titlebyCreateAPI',
              description: 'descByAPI',
              file: file
            )
            expect(asset).to be_kind_of Contentful::Management::Asset
            asset.publish
            expect(asset.published?).to be_truthy
          end
        end

        it 'returns Contentful::Management::Asset' do
          vcr('asset/publish') do
            asset = subject.find(asset_id_2)
            initial_version = asset.sys[:version]
            asset.publish
            expect(asset).to be_kind_of Contentful::Management::Asset
            expect(asset.sys[:version]).to eql initial_version + 1
          end
        end
        it 'returns BadRequest error when already published' do
          vcr('asset/publish_already_published') do
            asset = subject.find(asset_id_2)
            asset.sys[:version] = -1
            result = asset.publish
            expect(result).to be_kind_of Contentful::Management::Conflict
          end
        end
      end

      describe '#published?' do
        it 'returns true if asset is published' do
          vcr('asset/published_true') do
            asset = subject.find(asset_id)
            asset.publish
            expect(asset.published?).to be_truthy
          end
        end
        it 'returns false if asset is not published' do
          vcr('asset/published_false') do
            asset = subject.find(asset_id)
            asset.unpublish
            expect(asset.published?).to be_falsey
          end
        end
      end

      describe '#unarchive' do
        it 'unarchive the asset' do
          vcr('asset/unarchive') do
            asset = subject.find(asset_id_2)
            initial_version = asset.sys[:version]
            asset.unarchive
            expect(asset).to be_kind_of Contentful::Management::Asset
            expect(asset.sys[:version]).to eql initial_version + 1
          end
        end

        it 'returns BadRequest error when already unpublished' do
          vcr('asset/unarchive_already_unarchived') do
            result = subject.find(asset_id_2).unarchive
            expect(result).to be_kind_of Contentful::Management::BadRequest
          end
        end
      end

      describe '#archive' do
        it 'returns error when archive published asset' do
          vcr('asset/archive_published') do
            asset = subject.find(asset_id_2).archive
            expect(asset).to be_kind_of Contentful::Management::BadRequest
          end
        end

        it ' archive unpublished asset' do
          vcr('asset/archive') do
            asset = subject.find(asset_id_2)
            initial_version = asset.sys[:version]
            asset.archive
            expect(asset).to be_kind_of Contentful::Management::Asset
            expect(asset.sys[:version]).to eql initial_version + 1
          end
        end

        it 'returns BadRequest error when already unpublished' do
          vcr('asset/unarchive_already_unarchive') do
            result = subject.find(asset_id_2).unarchive
            expect(result).to be_kind_of Contentful::Management::BadRequest
          end
        end
      end

      describe '#archived?' do
        it 'returns true if asset is archive' do
          vcr('asset/archived_true') do
            asset = subject.find(asset_id_2)
            asset.archive
            expect(asset.archived?).to be_truthy
          end
        end
        it 'returns false if asset is not archive' do
          vcr('asset/archived_false') do
            asset = subject.find(asset_id_2)
            asset.unarchive
            expect(asset.archived?).to be_falsey
          end
        end
      end

      describe '#locale' do
        it 'returns default locale' do
          vcr('asset/locale') do
            asset = subject.find(asset_id_2)
            expect(asset.locale).to eq asset.default_locale
            expect(asset.title).to eq 'titlebyCreateAPI'
            expect(asset.description).to eq 'descByAPI'
          end
        end

        it 'set locale to given asset' do
          vcr('asset/set_locale') do
            asset = subject.find(asset_id_2)
            asset.locale = 'pl-Pl'
            expect(asset.sys[:locale]).to eq 'pl-Pl'
          end
        end
      end

      describe '.create' do
        it 'creates asset ' do
          vcr('asset/create') do
            file = Contentful::Management::File.new
            file.properties[:contentType] = 'image/jpeg'
            file.properties[:fileName] = 'pic1.jpg'
            file.properties[:upload] = 'https://upload.wikimedia.org/wikipedia/commons/c/c7/Gasometer_Berlin_Sch%C3%B6neberg_2011.jpg'

            asset = subject.create(
              title: 'titlebyCreateAPI',
              description: 'descByAPI',
              file: file
            )
            expect(asset).to be_kind_of Contentful::Management::Asset
            expect(asset.title).to eq 'titlebyCreateAPI'
            expect(asset.description).to eq 'descByAPI'
          end
        end

        it 'creates asset with specified locale ' do
          vcr('asset/create_with_locale') do
            file = Contentful::Management::File.new
            file.properties[:contentType] = 'image/jpeg'
            file.properties[:fileName] = 'pic1.jpg'
            file.properties[:upload] = 'https://upload.wikimedia.org/wikipedia/commons/c/c7/Gasometer_Berlin_Sch%C3%B6neberg_2011.jpg'

            asset = described_class.create(
              client,
              'bfsvtul0c41g',
              'master',
              title: 'Title PL',
              description: 'Description PL',
              file: file,
              locale: 'pl-PL'
            )
            expect(asset).to be_kind_of Contentful::Management::Asset
            expect(asset.title).to eq 'Title PL'
            expect(asset.description).to eq 'Description PL'
          end
        end

        it 'creates asset with custom ID' do
          vcr('asset/create_with_custom_id') do
            file = Contentful::Management::File.new
            file.properties[:contentType] = 'image/jpeg'
            file.properties[:fileName] = 'codequest.jpg'
            file.properties[:upload] = 'http://static.goldenline.pl/firm_logo/082/firm_225106_22f37f_small.jpg'

            asset = subject.create(
              id: 'codequest_id_test_custom',
              title: 'titlebyCreateAPI_custom_id',
              description: 'descByAPI_custom_id',
              file: file
            )
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

            asset = subject.create(
              id: 'codequest_id_test_custom_id',
              title: 'titlebyCreateAPI_custom_id',
              description: 'descByAPI_custom_id',
              file: file
            )
            expect(asset).to be_kind_of Contentful::Management::Conflict
          end
        end
      end

      describe '#update' do
        it 'updates asset with default locale without file' do
          vcr('asset/update_with_default_locale_without_file') do
            asset = subject.find('4DmT2j54pWY8ocimkEU6qS')
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

            asset = subject.find('4DmT2j54pWY8ocimkEU6qS')
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

            asset = subject.find('codequest_id_test_custom_id')
            asset.locale = 'pl'
            asset.update(title: 'updateTitlePl', description: 'updateDescPl', file: file)
            expect(asset).to be_kind_of Contentful::Management::Asset
            expect(asset.title).to eq 'updateTitlePl'
            expect(asset.description).to eq 'updateDescPl'
            expect(asset.file.properties[:fileName]).to eq 'codequest.jpg'
          end
        end
      end
      describe '#save' do
        it 'updated' do
          vcr('asset/save_update') do
            asset = subject.find('35Kt2tInIsoauo8sC82q04')
            asset.fields[:description] = 'Firmowe logo.'
            asset.save
            expect(asset).to be_kind_of Contentful::Management::Asset
            expect(asset.fields[:description]).to eq 'Firmowe logo.'
          end
        end
      end

      describe '#reload' do
        let(:space_id) { 'bfsvtul0c41g' }
        it 'update the current version of the object to the version on the system' do
          vcr('asset/reload') do
            asset = subject.find('8R4vbQXKbCkcSu26Wy2U0')
            asset.sys[:version] = 999
            update_asset = asset.update(title: 'Updated name')
            expect(update_asset).to be_kind_of Contentful::Management::Conflict
            asset.reload
            update_asset = asset.update(title: 'Updated name')
            expect(update_asset).to be_kind_of Contentful::Management::Asset
            expect(update_asset.title).to eq 'Updated name'

          end
        end

        it 'updates fields collection when reloaded' do
          vcr('asset/reload_with_fields') do
            asset = subject.find('8R4vbQXKbCkcSu26Wy2U0')
            valid_fields = asset.instance_variable_get(:@fields)
            asset.instance_variable_set(:@fields, 'changed')
            asset.reload
            reloaded_fields = asset.instance_variable_get(:@fields)
            expect(reloaded_fields['en-US']['description']).to eq valid_fields['en-US']['description']
            expect(reloaded_fields['en-US']['title']).to eq valid_fields['en-US']['title']
            expect(reloaded_fields['en-US']['file']).to eq valid_fields['en-US']['file']
          end
        end
      end

      describe '#image_url' do
        it 'empty_query' do
          asset = subject.new
          asset.file = double('file', url: 'http://assets.com/asset.jpg')
          expect(asset.image_url).to eq 'http://assets.com/asset.jpg'
        end
        it 'with_params' do
          asset = subject.new
          asset.file = double('file', url: 'http://assets.com/asset.jpg')
          expect(asset.image_url(w: 100, h: 100, fm: 'format', q: 1)).to eq 'http://assets.com/asset.jpg?w=100&h=100&fm=format&q=1'
        end
      end

      describe '#process' do
        let(:space_id) { 'bfsvtul0c41g' }
        it 'process file after create an asset' do
          vcr('asset/process') do
            file = Contentful::Management::File.new
            file.properties[:contentType] = 'image/jpeg'
            file.properties[:fileName] = 'pic1.jpg'
            file.properties[:upload] = 'https://upload.wikimedia.org/wikipedia/commons/c/c7/Gasometer_Berlin_Sch%C3%B6neberg_2011.jpg'

            asset = subject.create(title: 'Asset title', description: 'Description', file: file)
            asset.process_file
            expect(asset).to be_kind_of Contentful::Management::Asset
            expect(asset.title).to eq 'Asset title'
          end
        end
      end

      describe '#image_url' do
        it 'empty_query' do
          asset = subject.new
          asset.file = double('file', url: 'http://assets.com/asset.jpg')
          expect(asset.image_url).to eq 'http://assets.com/asset.jpg'
        end
        it 'with_params' do
          asset = subject.new
          asset.file = double('file', url: 'http://assets.com/asset.jpg')
          expect(asset.image_url(w: 100, h: 100, fm: 'format', q: 1)).to eq 'http://assets.com/asset.jpg?w=100&h=100&fm=format&q=1'
        end
      end

      describe 'issues' do
        describe "Pagination on assets doesn't work without first calling limit - #143" do
          it 'shouldnt break on next page without parameters on original query' do
            vcr('asset/143_assets_next_page') do
              assets = described_class.all(client, 'facgnwwgj5fe', 'master')
              assets.next_page
            end
          end
        end
      end
    end
  end
end
