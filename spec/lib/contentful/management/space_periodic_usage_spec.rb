require 'spec_helper'
require 'contentful/management/space'
require 'contentful/management/client'

module Contentful
  module Management
    describe SpacePeriodicUsage do
      let(:token) { ENV.fetch('CF_TEST_CMA_TOKEN', '<ACCESS_TOKEN>') }
      let(:organization_id) { 'org_id' }

      let!(:client) { Client.new(token) }

      subject { client.space_periodic_usages(organization_id) }

      describe '.all' do
        it 'class method also works' do
          vcr('space_periodic_usage/all') { expect(Contentful::Management::SpacePeriodicUsage.all(client, organization_id)).to be_kind_of Contentful::Management::Array }
        end
        it 'returns a Contentful::Array' do
          vcr('space_periodic_usage/all') { expect(subject.all).to be_kind_of Contentful::Management::Array }
        end
        it 'builds a Contentful::Management::SpacePeriodicUsage object' do
          vcr('space_periodic_usage/all') { expect(subject.all.first).to be_kind_of Contentful::Management::SpacePeriodicUsage }
        end
        it 'builds a Contentful::Management::SpacePeriodicUsage object' do
          vcr('space_periodic_usage/filters') { 
            result = subject.all('metric[in]' => 'cda')
            expect(result.all? { |pu| pu.metric == 'cda' }).to be_truthy
            expect(result.first).to be_kind_of Contentful::Management::SpacePeriodicUsage
            expect(result.first.metric).to eq 'cda'
          }
        end
      end
    end
  end
end
