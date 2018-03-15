require 'spec_helper'
require 'contentful/management/space'
require 'contentful/management/client'

module Contentful
  module Management
    describe ApiKey do
      let(:token) { '<ACCESS_TOKEN>' }
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
    end
  end
end

