require 'spec_helper'
require 'contentful/management/space'
require 'contentful/management/client'

module Contentful
  module Management
    describe Space do
      let(:token) { ENV.fetch('CF_TEST_CMA_TOKEN', '<ACCESS_TOKEN>') }
      let(:space_id) { 'yr5m0jky5hsh' }

      let!(:client) { Client.new(token) }

      subject { client.spaces }

      describe '.all' do
        it 'class method also works' do
          vcr('space/all') { expect(Contentful::Management::Space.all(client)).to be_kind_of Contentful::Management::Array }
        end
        it 'returns a Contentful::Array' do
          vcr('space/all') { expect(subject.all).to be_kind_of Contentful::Management::Array }
        end
        it 'builds a Contentful::Management::Space object' do
          vcr('space/all') { expect(subject.all.first).to be_kind_of Contentful::Management::Space }
        end
      end

      describe '.find' do
        it 'class method also works' do
          vcr('space/find') { expect(Contentful::Management::Space.find(client, space_id)).to be_kind_of Contentful::Management::Space }
        end
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
          vcr('space/locale/find') do
            space = subject.find(space_id)
            expect(space.id).to eql space_id
            expect(space.default_locale).to eql 'en-US'
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
            end
          end
          it 'creates a space within a client default locale' do
            vcr('space/create_with_client_default_locale') do
              client = Client.new('<ACCESS_TOKEN>', default_locale: 'pl-PL')
              space = client.spaces.create(name: 'new space', organization_id: '4SsuxQCaMaemfIms52Jr8s')
              expect(space).to be_kind_of Contentful::Management::Space
              expect(space.name).to eq 'new space'
              expect(space.default_locale).to eql 'pl-PL'
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

      describe '#api_keys' do
        let!(:space_id) { 'bjwq7b86vgmm' }
        let(:api_key_id) { '6vbW35TjBTc8FyRTAuXZZe' }
        let(:api_key_name) { 'ApiKeyForSpace' }

        it '#api_keys.create' do
          vcr('space/api_key/create') do
            api_key = subject.find(space_id).api_keys.create(name: api_key_name)
            expect(api_key).to be_kind_of Contentful::Management::ApiKey
            expect(api_key.name).to eq api_key_name
          end
        end
        it '#api_keys.find' do
          vcr('space/api_key/find') do
            api_key = subject.find(space_id).api_keys.find(api_key_id)
            expect(api_key).to be_kind_of Contentful::Management::ApiKey
            expect(api_key.name).to eq 'testKey'
            expect(api_key.access_token).to eq '833ea085204398499ea424c8ad832f1ae1cac4d64e2cc56db774aff87ef20b33'
          end
        end
        it '#api_keys.all' do
          vcr('space/api_key/all') do
            api_keys = subject.find(space_id).api_keys.all
            expect(api_keys).to be_kind_of Contentful::Management::Array
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
