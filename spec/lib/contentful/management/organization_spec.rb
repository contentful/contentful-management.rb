require 'spec_helper'
require 'contentful/management/space'
require 'contentful/management/client'

module Contentful
  module Management
    describe Organization do
      let(:token) { ENV.fetch('CF_TEST_CMA_TOKEN', '<ACCESS_TOKEN>') }
      let!(:client) { Client.new(token) }

      subject { client.organizations }

      describe '.all' do
        it 'fetches the list of organizations belonging to the user' do
          vcr('organization/all') {
            organizations = subject.all
            expect(organizations).to be_a Contentful::Management::Array

            expect(organizations.first).to be_a Contentful::Management::Organization
            expect(organizations.first.name).to eq 'My Test Organization'
            expect(organizations.first.id).to be_truthy
          }
        end
      end

      describe '.find' do
        it 'is not supported' do
          expect { subject.find }.to raise_error 'Not supported'
        end
      end
    end
  end
end
