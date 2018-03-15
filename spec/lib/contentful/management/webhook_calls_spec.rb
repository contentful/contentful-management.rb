require 'spec_helper'
require 'contentful/management/space'
require 'contentful/management/client'

module Contentful
  module Management
    describe WebhookCall do
      let(:token) { ENV.fetch('CF_TEST_CMA_TOKEN', '<ACCESS_TOKEN>') }
      let(:space_id) { 'orzkxlxlq59d' }
      let(:webhook_id) { '16ypL3XjNK6oreLPPoVBxI' }
      let(:webhook_call_id) { '6r2EQ0iVBmYyyq0UMWKoge' }
      let!(:client) { Client.new(token) }

      subject { client.webhook_calls(space_id, webhook_id) }

      describe '.all' do
        it 'class method also works' do
          vcr('webhook_call/all') { expect(Contentful::Management::WebhookCall.all(client, space_id, webhook_id)).to be_kind_of Contentful::Management::Array }
        end
        it 'returns a Contentful::Array' do
          vcr('webhook_call/all') { expect(subject.all).to be_kind_of Contentful::Management::Array }
        end
        it 'builds a Contentful::Management::WebhookCall object' do
          vcr('webhook_call/all') {
            webhook_call = subject.all.first

            expect(webhook_call).to be_kind_of Contentful::Management::WebhookCall
            expect(webhook_call.id).to be_truthy
            expect(webhook_call.status_code).to eq 201
            expect(webhook_call.event_type).to eq "publish"
            expect(webhook_call.errors).to be_empty
            expect(webhook_call.response_at).to be_truthy
            expect(webhook_call.url).to eq "https://circleci.com/api/v1/project/virgendeloreto/blog_source/tree/master?circle-token=foobar"
            expect(webhook_call.request_at).to be_truthy
          }
        end
      end

      describe '.find' do
        it 'class method also works' do
          vcr('webhook_call/find') { expect(Contentful::Management::WebhookCall.find(client, space_id, webhook_id, webhook_call_id)).to be_kind_of Contentful::Management::WebhookCall }
        end
        it 'returns a Contentful::Management::WebhookCall' do
          vcr('webhook_call/find') { expect(subject.find(webhook_call_id)).to be_kind_of Contentful::Management::WebhookCall }
        end
        it 'returns webhook for a given id' do
          vcr('webhook_call/find') do
            webhook_call = subject.find(webhook_call_id)
            expect(webhook_call.id).to eq webhook_call_id
            expect(webhook_call.status_code).to eq 201
            expect(webhook_call.event_type).to eq "publish"
            expect(webhook_call.errors).to be_empty
            expect(webhook_call.response_at).to be_truthy
            expect(webhook_call.url).to be_truthy
            expect(webhook_call.request_at).to be_truthy
            expect(webhook_call.request).to be_truthy
            expect(webhook_call.response).to be_truthy
          end
        end
        it 'returns an error when call does not exists' do
          vcr('webhook_call/find_not_found') do
            result = subject.find('not_exist')
            expect(result).to be_kind_of Contentful::Management::NotFound
          end
        end
      end
    end
  end
end
