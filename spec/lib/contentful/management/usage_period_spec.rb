require 'spec_helper'
require 'contentful/management/client'

module Contentful
  module Management
    describe ApiKey do
      let(:token) { ENV.fetch('CF_TEST_CMA_TOKEN', '<ACCESS_TOKEN>') }
      let(:organization_id) { 'org_id' }

      let!(:client) { Client.new(token ) }

      subject { client.usage_periods(organization_id) }

      describe '.all' do
        it 'class method also works' do
          vcr('usage_period/all') { expect(Contentful::Management::UsagePeriod.all(client, organization_id)).to be_kind_of Contentful::Management::Array }
        end
        it 'returns a Contentful::Array' do
          vcr('usage_period/all') { expect(subject.all).to be_kind_of Contentful::Management::Array }
        end
        it 'builds a Contentful::Management::UsagePeriod object' do
          vcr('usage_period/all') { expect(subject.all.first).to be_kind_of Contentful::Management::UsagePeriod }
        end
      end
    end
  end
end
