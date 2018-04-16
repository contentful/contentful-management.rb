require 'spec_helper'
require 'contentful/management/space'
require 'contentful/management/client'

module Contentful
  module Management
    describe WebhookHealth do
      let(:token) { ENV.fetch('CF_TEST_CMA_TOKEN', '<ACCESS_TOKEN>') }
      let(:space_id) { 'orzkxlxlq59d' }
      let(:webhook_id) { '16ypL3XjNK6oreLPPoVBxI' }
      let!(:client) { Client.new(token) }

      subject { client.webhook_health(space_id) }

      describe '.all' do
        it 'is not supported' do
          expect { subject.all }.to raise_error 'Not supported'
        end
      end

      describe '.find' do
        it 'class method also works' do
          vcr('webhook_health/find') {
            expect(Contentful::Management::WebhookHealth.find(
              client,
              space_id,
              webhook_id
            )).to be_kind_of Contentful::Management::WebhookHealth
          }
        end
        it 'returns a Contentful::Management::WebhookHealth' do
          vcr('webhook_health/find') { expect(subject.find(webhook_id)).to be_kind_of Contentful::Management::WebhookHealth }
        end
        it 'returns webhook for a given id' do
          vcr('webhook_health/find') do
            webhook_health = subject.find(webhook_id)
            expect(webhook_health.calls).to be_a ::Hash

            expect(webhook_health.calls['total']).to eq 2
            expect(webhook_health.calls['healthy']).to eq 2

            expect(webhook_health.healthy).to eq 2
            expect(webhook_health.total).to eq 2
            expect(webhook_health.errors?).to eq false
            expect(webhook_health.healthy?).to eq true
          end
        end
      end
    end
  end
end
