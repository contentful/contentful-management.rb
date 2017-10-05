require 'spec_helper'
require 'contentful/management/space'
require 'contentful/management/client'

module Contentful
  module Management
    describe User do
      let(:token) { ENV.fetch('CF_TEST_CMA_TOKEN', '<ACCESS_TOKEN>') }
      let!(:client) { Client.new(token) }

      subject { client.users }

      describe '.all' do
        it 'is not supported' do
          expect { subject.all }.to raise_error 'Not supported'
        end
      end

      describe '.find' do
        it 'fetches the current user' do
          vcr('user/find') {
            user = subject.find('me')
            expect(user).to be_a Contentful::Management::User
            expect(user.first_name).to eq 'David'
            expect(user.last_name).to eq 'Test'
            expect(user.email).to eq 'david.test@testytest.com'
            expect(user.activated).to eq true
            expect(user.confirmed).to eq true
            expect(user.sign_in_count).to eq 26
            expect(user.avatar_url).to be_truthy
          }
        end
      end

      describe '.me' do
        it 'is an alias to .find("me")' do
          vcr('user/find') {
            user = subject.me
            expect(user).to be_a Contentful::Management::User
            expect(user.first_name).to eq 'David'
            expect(user.last_name).to eq 'Test'
            expect(user.email).to eq 'david.test@testytest.com'
            expect(user.activated).to eq true
            expect(user.confirmed).to eq true
            expect(user.sign_in_count).to eq 26
            expect(user.avatar_url).to be_truthy
          }
        end
      end
    end
  end
end
