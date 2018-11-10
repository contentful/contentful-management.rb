require 'spec_helper'
require 'contentful/management/space'
require 'contentful/management/client'

module Contentful
  module Management
    describe ApiKey do
      let(:token) { ENV.fetch('CF_TEST_CMA_TOKEN', '<ACCESS_TOKEN>') }
      let(:organization_id) { 'org_id' }

      let!(:client) { Client.new(token ) }

      subject { client.api_usage(organization_id) }

      describe '.all' do
        it 'class method also works' do
          vcr('api_usage/all') { expect(Contentful::Management::ApiUsage.all(client, organization_id, 'organization', 1, 'cda')).to be_kind_of Contentful::Management::Array }
        end
        it 'returns a Contentful::Array' do
          vcr('api_usage/all') { expect(subject.all('organization', 1, 'cda')).to be_kind_of Contentful::Management::Array }
        end
        it 'builds a Contentful::Management::ApiUsage object' do
          vcr('api_usage/all') { expect(subject.all('organization', 1, 'cda').first).to be_kind_of Contentful::Management::ApiUsage }
        end
      end
    end
  end
end
