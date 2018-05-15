require 'spec_helper'
require 'contentful/management/space'
require 'contentful/management/client'

module Contentful
  module Management
    describe ApiKey do
      let(:token) { ENV.fetch('CF_TEST_CMA_TOKEN', '<ACCESS_TOKEN>') }
      let(:space_id) { 'bjwq7b86vgmm' }
      let(:api_key_id) { '6vbW35TjBTc8FyRTAuXZZe' }

      let!(:client) { Client.new(token) }

      subject { client.api_keys(space_id) }

      describe '.all' do
        it 'class method also works' do
          vcr('api_key/all_for_space') { expect(Contentful::Management::ApiKey.all(client, space_id)).to be_kind_of Contentful::Management::Array }
        end
        it 'returns a Contentful::Array' do
          vcr('api_key/all_for_space') { expect(subject.all).to be_kind_of Contentful::Management::Array }
        end
        it 'builds a Contentful::Management::ApiKey object' do
          vcr('api_key/all_for_space') { expect(subject.all.first).to be_kind_of Contentful::Management::ApiKey }
        end
      end

      describe '.find' do
        it 'class method also works' do
          vcr('api_key/find') { expect(Contentful::Management::ApiKey.find(client, space_id, api_key_id)).to be_kind_of Contentful::Management::ApiKey }
        end
        it 'returns a Contentful::Management::ApiKey' do
          vcr('api_key/find') { expect(subject.find(api_key_id)).to be_kind_of Contentful::Management::ApiKey }
        end
        it 'returns the api_key for a given key' do
          vcr('api_key/find') do
            api_key = subject.find(api_key_id)
            expect(api_key.id).to eql api_key_id
            expect(api_key.access_token).to eql '833ea085204398499ea424c8ad832f1ae1cac4d64e2cc56db774aff87ef20b33'
          end
        end
        it 'returns an error when api_key does not exists' do
          vcr('api_key/find_for_space_not_found') do
            result = subject.find('not_exist')
            expect(result).to be_kind_of Contentful::Management::NotFound
          end
        end
      end

      describe '.create' do
        it 'create api_keys for space' do
          vcr('api_key/create_for_space') do
            api_key = subject.create(name: 'testLocalCreate', description: 'bg')
            expect(api_key.name).to eql 'testLocalCreate'
          end
        end
      end

      describe 'environments' do
        let(:space_id) { 'facgnwwgj5fe' }
        subject { client.api_keys(space_id) }

        it 'can create an api key with environments' do
          vcr('api_key/create_with_environments') {
            api_key = subject.create(name: 'test with env', environments: [
              {
                sys: {
                  type: 'Link',
                  linkType: 'Environment',
                  id: 'master'
                }
              },
              {
                sys: {
                  type: 'Link',
                  linkType: 'Environment',
                  id: 'testing'
                }
              }
            ])
            expect(api_key.environments.size).to eq 2
            expect(api_key.environments.first.id).to eq 'master'
            expect(api_key.environments.last.id).to eq 'testing'
          }
        end
      end

      describe 'preview api tokens' do
        let(:space_id) { 'facgnwwgj5fe' }
        let(:api_key_id) { '5mxNhKOZYOp1wzafOR9qPw' }
        subject { client.api_keys(space_id) }

        it 'can fetch preview api keys' do
          vcr('api_key/preview') {
            api_key = subject.find(api_key_id)

            expect(api_key.properties[:preview_api_key]).to be_a Contentful::Management::Link

            preview_api_key = api_key.preview_api_key
            expect(preview_api_key).to be_a Contentful::Management::PreviewApiKey
            expect(preview_api_key.access_token).to eq 'PREVIEW_TOKEN'
          }
        end
      end
    end
  end
end

