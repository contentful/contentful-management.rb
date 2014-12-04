require 'spec_helper'
require 'contentful/management/space'
require 'contentful/management/client'

module Contentful
  module Management
    describe Space do
      let(:token) { '<ACCESS_TOKEN>' }
      let(:space_id) { 'yr5m0jky5hsh' }

      let!(:client) { Client.new(token) }

      subject { Contentful::Management::Space }

      describe '.all' do
        it 'returns a Contentful::Array' do
          vcr('space/all') { expect(subject.all).to be_kind_of Contentful::Management::Array }
        end
        it 'builds a Contentful::Management::Space object' do
          vcr('space/all') { expect(subject.all.first).to be_kind_of Contentful::Management::Space }
        end
      end

      describe '.find' do
        it 'returns a Contentful::Management::Space' do
          vcr('space/find') { expect(subject.find(space_id)).to be_kind_of Contentful::Management::Space }
        end
        it 'returns space for a given key' do
          vcr('space/find') do
            space = subject.find(space_id)
            expect(space.id).to eql space_id
          end
        end
        it 'returns an error when space not found' do
          vcr('space/find_not_found') do
            result = subject.find('not_exist')
            expect(result).to be_kind_of Contentful::Management::NotFound
          end
        end
        it 'returns space for a given key' do
          vcr('space/find') do
            space = subject.find(space_id)
            expect(space.id).to eql space_id
          end
        end
      end

      describe '#destroy' do
        it 'returns true when a space was deleted' do
          vcr('space/destory') do
            result = subject.find('aopzqyf8j4yq').destroy
            expect(result).to eql true
          end
        end
      end

      describe '.create' do
        let(:space_name) { 'My Test Space' }
        let(:organization_id) { '0fV1n3ykR3arQQAa8aylMi' }

        it 'creates a space within an organization' do
          vcr('space/create') do
            space = subject.create(name: space_name, organization_id: organization_id)
            expect(space).to be_kind_of Contentful::Management::Space
            expect(space.name).to eq space_name
          end
        end
        it 'creates a space when the user only has one organization' do
          vcr('space/create_without_organization') do
            space = subject.create(name: space_name)
            expect(space).to be_kind_of Contentful::Management::Space
            expect(space.name).to eq space_name
          end
        end
        it 'returns error when user have multiple organizations and not pass organization_id' do
          vcr('space/create_with_unknown_organization') do
            space = subject.create(name: space_name)
            expect(space).to be_kind_of Contentful::Management::NotFound
          end
        end
        it 'returns error when limit has been reached' do
          vcr('space/create_when_limit_has_been_reached') do
            space = subject.create(name: space_name, organization_id: organization_id)
            expect(space).to be_kind_of Contentful::Management::AccessDenied
          end
        end
        context 'create with locale' do
          it 'creates a space within a specified default locale' do
            vcr('space/create_with_locale') do
              space = subject.create(name: 'pl space', organization_id: '1EQPR5IHrPx94UY4AViTYO', default_locale: 'pl-pl')
              expect(space).to be_kind_of Contentful::Management::Space
              expect(space.name).to eq 'pl space'
              expect(space.locales.all.first.code).to eql 'pl-pl'
            end
          end
          it 'creates a space within a client default locale' do
            vcr('space/create_with_client_default_locale') do
              Client.new('<ACCESS_TOKEN>', default_locale: 'pl-PL')
              space = subject.create(name: 'new space', organization_id: '1EQPR5IHrPx94UY4AViTYO')
              expect(space).to be_kind_of Contentful::Management::Space
              expect(space.name).to eq 'new space'
              expect(space.locales.all.first.code).to eql 'pl-PL'
            end
          end
        end
      end

      describe '#update' do
        it 'updates the space name and increase version by +1' do
          vcr('space/update') do
            space = subject.find(space_id)
            initial_version = space.sys[:version]
            space.update(name: 'NewNameSpace')
            expect(space.sys[:version]).to eql initial_version + 1
          end
        end
        it 'update name to the same name not increase version' do
          vcr(:'space/update_with_the_same_data') do
            space = subject.find(space_id)
            initial_version = space.sys[:version]
            space.update(name: 'NewNameSpace')
            expect(space.sys[:version]).to eql initial_version
          end
        end
      end

      describe '#content_types' do
        let(:content_type_id) { '5DSpuKrl04eMAGQoQckeIq' }
        let(:content_type_name) { 'ContentTypeForSpace' }

        it 'creates content type' do
          vcr('space/content_type/create') do
            content_type = subject.find(space_id).content_types.create(name: content_type_name)
            expect(content_type).to be_kind_of Contentful::Management::ContentType
            expect(content_type.name).to eq content_type_name
          end
        end
        it '#content_types.find' do
          vcr('space/content_type/find') do
            content_type = subject.find(space_id).content_types.find('1AZQOWKr2I8W2ugY0KiGEU')
            expect(content_type).to be_kind_of Contentful::Management::ContentType
            expect(content_type.name).to eq content_type_name
          end
        end
        it '.content_types.all' do
          vcr('space/content_type/all') do
            content_types = subject.find(space_id).content_types.all
            expect(content_types).to be_kind_of Contentful::Management::Array
          end
        end
      end

      describe '#locales' do
        let(:locale_id) { '42irhRZ5uMrRc9SZ1PyDRk' }

        it '#locales.all' do
          vcr('space/locale/all') do
            locales = subject.find(space_id).locales.all
            expect(locales).to be_kind_of Contentful::Management::Array
          end
        end
        it 'builds a Contentful::Management::Local object' do
          vcr('space/locale/all') { expect(subject.find(space_id).locales.all.first).to be_kind_of Contentful::Management::Locale }
        end
        it '#locales.find' do
          vcr('space/locale/find') do
            locales = subject.find(space_id).locales.find(locale_id)
            expect(locales).to be_kind_of Contentful::Management::Locale
            expect(locales.code).to eql 'en-US'
          end
        end

        it 'when locale not found' do
          vcr('space/locale/find_not_found') do
            locale = subject.find(space_id).locales.find('invalid_id')
            expect(locale).to be_kind_of Contentful::Management::NotFound
          end
        end

        it 'creates locales to space' do
          vcr('space/locale/create') do
            locale = subject.find(space_id).locales.create(name: 'ru-RU',
                                                           contentManagementApi: true,
                                                           publish: true,
                                                           contentDeliveryApi: true,
                                                           code: 'ru-RU')
            expect(locale).to be_kind_of Contentful::Management::Locale
            expect(locale.name).to eql 'ru-RU'
          end
        end

        it 'returns error when locale already exists' do
          vcr('space/locale/create_with_the_same_code') do
            space = subject.find(space_id)
            locale = space.locales.create(name: 'ru-RU',
                                          contentManagementApi: true,
                                          publish: true,
                                          contentDeliveryApi: true,
                                          code: 'ru-RU')
            expect(locale).to be_kind_of Contentful::Management::UnprocessableEntity
            expect(locale.response.error_message).to eql 'The resource you sent in the body is invalid.'
          end
        end

        it '#update when all params are given' do
          vcr('space/locale/update') do
            locale = subject.find(space_id).locales.find('6vn9hLab7q0D44XgRUwpoO')
            initial_version = locale.sys[:version]
            locale.update(name: 'Russia', contentManagementApi: true, publish: true, contentDeliveryApi: true)
            expect(locale).to be_kind_of Contentful::Management::Locale
            expect(locale.name).to eql 'Russia'
            expect(locale.sys[:version]).to eql initial_version + 1
          end
        end
      end

      describe '#save' do
        let(:new_name) { 'SaveNewName' }
        it ' new space' do
          vcr('space/save_new_space') do
            space = subject.new
            space.name = new_name
            space.save
            expect(space).to be_kind_of Contentful::Management::Space
            expect(space.name).to eq new_name
          end
        end
        it 'update space' do
          vcr('space/save_update_space') do
            space = subject.find(space_id)
            space.name = new_name
            space.save
            expect(space).to be_kind_of Contentful::Management::Space
            expect(space.name).to eq new_name
          end
        end
      end

      describe '#assets' do
        it '#assets.all' do
          vcr('space/asset/all') do
            assets = subject.find(space_id).assets.all
            expect(assets).to be_kind_of Contentful::Management::Array
          end
        end
        it 'builds a Contentful::Management::Asset object' do
          vcr('space/asset/all') { expect(subject.find(space_id).assets.all.first).to be_kind_of Contentful::Management::Asset }
        end

        it 'return asset for a given key' do
          vcr('space/asset/find') do
            result = subject.find(space_id).assets.find('6zEogZjpO8cq6YOOQigiAw')
            expect(result).to be_kind_of Contentful::Management::Asset
            expect(result.id).to eql '6zEogZjpO8cq6YOOQigiAw'
          end
        end
        it '#assets.all(skip: 3, limit: 5)' do
          vcr('space/asset/all_with_skip_and_limit') do
            assets = subject.find('bfsvtul0c41g').assets.all(limit: 5, skip: 3)
            expect(assets).to be_kind_of Contentful::Management::Array
            expect(assets.limit).to eq 5
          end
        end

        it 'create asset for space' do
          vcr('space/asset/create') do
            file = Contentful::Management::File.new
            file.properties[:contentType] = 'image/jpeg'
            file.properties[:fileName] = 'codequest.jpg'
            file.properties[:upload] = 'http://static.goldenline.pl/firm_logo/082/firm_225106_22f37f_small.jpg'

            space_assets = subject.find(space_id).assets
            asset = space_assets.create(title: 'CodeQuest', description: 'Logo of Codequest', file: file)
            expect(asset).to be_kind_of Contentful::Management::Asset
            expect(asset.title).to eql 'CodeQuest'
            expect(asset.description).to eql 'Logo of Codequest'
          end
        end

        it 'creates asset with  multiple locales ' do
          vcr('space/asset/create_with_multiple_locales') do
            file = Contentful::Management::File.new
            file.properties[:contentType] = 'image/jpeg'
            file.properties[:fileName] = 'codequest.jpg'
            file.properties[:upload] = 'http://static.goldenline.pl/firm_logo/082/firm_225106_22f37f_small.jpg'
            space = subject.find(space_id)
            asset = space.assets.new
            asset.title_with_locales = {'en-US' => 'Company logo', 'pl' => 'Firmowe logo'}
            asset.title = 'Logo of Codequest comapny'
            asset.description_with_locales = {'en-US' => 'Company logo codequest', 'pl' => 'Logo firmy Codequest'}
            asset.file_with_locales = {'en-US' => file, 'pl' => file}
            asset.save

            expect(asset).to be_kind_of Contentful::Management::Asset
            expect(asset.title).to eq 'Logo of Codequest comapny'
            expect(asset.description).to eq 'Company logo codequest'
            asset.locale = 'pl'
            expect(asset.title).to eq 'Firmowe logo'
            expect(asset.description).to eq 'Logo firmy Codequest'
          end
        end
      end
      describe '#assets.all(limit: 2, skip: 1).next_page' do
        it 'returns assets to limited number of assets' do
          vcr('space/asset/with_skipped_and_limited_assets_next_page') do
            space = subject.find('bfsvtul0c41g')
            assets = space.assets.all(limit: 2, skip: 1).next_page
            expect(assets).to be_kind_of Contentful::Management::Array
            expect(assets.first).to be_kind_of Contentful::Management::Asset
            expect(assets.limit).to eq 2
            expect(assets.skip).to eq 3
          end
        end
      end

      describe '#entries' do
        it '#entries.all' do
          vcr('space/entry/all') do
            entries = subject.find(space_id).entries.all
            expect(entries).to be_kind_of Contentful::Management::Array
          end
        end
        it 'builds a Contentful::Management::Entry object' do
          vcr('space/entry/all') { expect(subject.find(space_id).entries.all.first).to be_kind_of Contentful::Management::Entry }
        end
        it 'return entry for a given key' do
          vcr('space/entry/find') do
            result = subject.find(space_id).entries.find('4Rouux8SoUCKwkyCq2I0E0')
            expect(result).to be_kind_of Contentful::Management::Entry
            expect(result.id).to eql '4Rouux8SoUCKwkyCq2I0E0'
            expect(result.name_with_locales['en-US']).to eq 'Tom Handy'
            expect(result.class.to_s).to eq "Contentful::Management::DynamicEntry[#{ result.class.content_type.id }]"
            expect(result.class.inspect).to eq "Contentful::Management::DynamicEntry[#{ result.class.content_type.id }]"
          end
        end
      end

      describe '#webhooks' do
        let(:space_id) { 'bfsvtul0c41g' }
        it 'return all webhooks' do
          vcr('space/webhook/all') do
            space = subject.find(space_id)
            webhooks = space.webhooks.all
            expect(webhooks).to be_kind_of Contentful::Management::Array
            expect(webhooks.first).to be_kind_of Contentful::Management::Webhook
          end
        end
        it 'return webhook for a given key' do
          vcr('space/webhook/find') do
            space = subject.find(space_id)
            webhook = space.webhooks.find('16X4KNhhfJti6Uq7x7EFQa')
            expect(webhook).to be_kind_of Contentful::Management::Webhook
            expect(webhook.url).to eql 'https://www.example2.com'
          end
        end
        it 'create' do
          vcr('space/webhook/create') do
            space = subject.find('v2umtz8ths9v')
            webhook = space.webhooks.create(url: 'https://www.example2.com', httpBasicUsername: 'username', httpBasicPassword: 'password')
            expect(webhook).to be_kind_of Contentful::Management::Webhook
            expect(webhook.url).to eql 'https://www.example2.com'
            expect(webhook.http_basic_username).to eql 'username'
          end
        end
      end
      describe '#entries.all(content_type: content_type_id)' do
        it 'returns entries to specified content type' do
          vcr('space/entry/content_type_entires') do
            space = subject.find('9lxkhjnp8gyx')
            entries = space.entries.all(content_type: 'category_content_type')
            expect(entries).to be_kind_of Contentful::Management::Array
            expect(entries.first).to be_kind_of Contentful::Management::Entry
            expect(entries.first.sys[:contentType].id).to eq 'category_content_type'
          end
        end
      end
      describe '#entries.all(limit: 2, skip: 1).next_page' do
        it 'returns entries to limited number of entries' do
          vcr('space/entry/with_skipped_and_limited_entires_next_page') do
            space = subject.find('sueu9bzev6qn')
            entries = space.entries.all(limit: 2, skip: 1).next_page
            expect(entries).to be_kind_of Contentful::Management::Array
            expect(entries.first).to be_kind_of Contentful::Management::Entry
            expect(entries.limit).to eq 2
            expect(entries.skip).to eq 3
          end
        end
      end
      describe '#reload' do
        let(:space_id) { 'bfsvtul0c41g' }
        it 'update the current version of the object to the version on the system' do
          vcr('space/reload') do
            space = subject.find(space_id)
            space.sys[:version] = 99
            space.reload
            update_space = space.update(name: 'Reload Space Name')
            expect(update_space).to be_kind_of Contentful::Management::Space
            expect(space.name).to eql 'Reload Space Name'
          end
        end
      end
    end
  end
end
