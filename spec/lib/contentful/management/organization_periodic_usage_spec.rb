require 'spec_helper'
require 'contentful/management/space'
require 'contentful/management/client'

module Contentful
  module Management
    describe OrganizationPeriodicUsage do
      let(:token) { ENV.fetch('CF_TEST_CMA_TOKEN', '<ACCESS_TOKEN>') }
      let(:organization_id) { 'org_id' }

      let!(:client) { Client.new(token) }

      subject { client.organization_periodic_usages(organization_id) }

      describe '.all' do
        it 'class method also works' do
          vcr('organization_periodic_usage/all') { expect(Contentful::Management::OrganizationPeriodicUsage.all(client, organization_id)).to be_kind_of Contentful::Management::Array }
        end
        it 'returns a Contentful::Array' do
          vcr('organization_periodic_usage/all') { expect(subject.all).to be_kind_of Contentful::Management::Array }
        end
        it 'builds a Contentful::Management::OrganizationPeriodicUsage object' do
          vcr('organization_periodic_usage/all') { expect(subject.all.first).to be_kind_of Contentful::Management::OrganizationPeriodicUsage }
        end
        it 'builds a Contentful::Management::OrganizationPeriodicUsage object' do
          vcr('organization_periodic_usage/filters') { 
            result = subject.all('metric[in]' => 'cda')
            expect(result.size).to eq 1
            expect(result.first).to be_kind_of Contentful::Management::OrganizationPeriodicUsage
            expect(result.first.metric).to eq 'cda'
          }
        end
      end
    end
  end
end
