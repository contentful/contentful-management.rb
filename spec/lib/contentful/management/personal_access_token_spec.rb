require 'spec_helper'
require 'contentful/management/space'
require 'contentful/management/client'

module Contentful
  module Management
    describe PersonalAccessToken do
      let(:token) { ENV.fetch('CF_TEST_CMA_TOKEN', '<ACCESS_TOKEN>') }
      let(:pat_id) { '3XBnbqn5s7oJ5PxyZiTzIg' }
      let!(:client) { Client.new(token) }

      subject { client.personal_access_tokens }

      describe '.all' do
        it 'returns a Contentful::Array' do
          vcr('personal_access_token/all') { expect(subject.all).to be_kind_of Contentful::Management::Array }
        end
        it 'builds a Contentful::Management::PersonalAccessToken object' do
          vcr('personal_access_token/all') {
            token = subject.all.first
            expect(token).to be_kind_of Contentful::Management::PersonalAccessToken
            expect(token.name).to eq 'Playground'
            expect(token.revoked_at).to be_falsey
            expect(token.scopes).not_to be_empty
          }
        end
      end

      describe '.find' do
        it 'returns a Contentful::Management::Webhook' do
          vcr('personal_access_token/find') { expect(subject.find(pat_id)).to be_kind_of Contentful::Management::PersonalAccessToken }
        end
        it 'returns webhook for a given key' do
          vcr('personal_access_token/find') do
            token = subject.find(pat_id)
            expect(token.id).to eql pat_id
            expect(token.name).to eq 'Playground'
            expect(token.revoked_at).to be_falsey
            expect(token.scopes).not_to be_empty
          end
        end
        it 'returns an error when content_type does not exists' do
          vcr('personal_access_token/find_not_found') do
            result = subject.find('not_exist')
            expect(result).to be_kind_of Contentful::Management::NotFound
          end
        end
      end

      describe '.create' do
        it 'builds Contentful::Management::PersonalAccessToken object' do
          vcr('personal_access_token/create') do
            token = subject.create(name: 'Test Token', scopes: ["content_management_manage"])
            expect(token).to be_kind_of Contentful::Management::PersonalAccessToken
            expect(token.name).to eq 'Test Token'
            expect(token.token).to eq 'CFPAT-testytest'
            expect(token.scopes).to eq ['content_management_manage']
          end
        end
      end

      describe '#destroy' do
        it 'is not supported' do
          vcr('personal_access_token/find') do
            token = subject.find(pat_id)
            expect { token.destroy }.to raise_error 'Not supported'
          end
        end
      end

      describe '#revoke' do
        it 'revokes a token' do
          vcr('personal_access_token/revoke') do
            token = subject.find('4us7wI40rNxTDzLuLl79dA')
            expect(token.revoked_at).to be_falsey

            token.revoke

            expect(token.revoked_at).to be_truthy
          end
        end
      end
    end
  end
end
