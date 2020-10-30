require 'spec_helper'
require 'contentful/management/client'

module Contentful
  module Management
    describe OrganizationUser do
      let(:token) { ENV.fetch('CF_TEST_CMA_TOKEN', '<ACCESS_TOKEN>') }
      let(:organization_id) { 'org_id' }

      let!(:client) { Client.new(token) }

      subject { client.organization_users(organization_id) }

      describe '.find' do
        it "should fetch the user if under the organizaton id" do
          vcr('organization_user/find') {
            user = subject.find('user_id')

            expect(user).to be_a Contentful::Management::User
            expect(user.first_name).to eq 'Bhushan'
            expect(user.last_name).to eq 'Lodha'
            expect(user.email).to eq 'bhushanlodha@gmail.com'
            expect(user.activated).to eq true
            expect(user.confirmed).to eq true
            expect(user.sign_in_count).to eq 42
            expect(user.avatar_url).to be_truthy
          }
        end
      end
    end
  end
end
