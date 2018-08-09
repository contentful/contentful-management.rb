require 'spec_helper'
require 'contentful/management/space'
require 'contentful/management/client'

module Contentful
  module Management
    describe SpaceMembership do
      let(:token) { ENV.fetch('CF_TEST_CMA_TOKEN', '<ACCESS_TOKEN>') }
      let(:space_id) { 'facgnwwgj5fe' }
      let(:membership_id) { '6RdRdobdQzh8zKe1Hogiz4' }
      let(:client) { Client.new(token, raise_errors: true) }

      subject { client.space_memberships(space_id) }

      describe 'class methods' do
        describe '::create_attributes' do
          it 'requires admin, roles and email keys to be present' do
            expect { described_class.create_attributes(nil, {}) }.to raise_error KeyError
            expect { described_class.create_attributes(nil, admin: true) }.to raise_error KeyError
            expect { described_class.create_attributes(nil, admin: true, roles: []) }.to raise_error KeyError
            expect { described_class.create_attributes(nil, roles: []) }.to raise_error KeyError
            expect { described_class.create_attributes(nil, roles: [], email: 'foo@bar.com') }.to raise_error KeyError
            expect { described_class.create_attributes(nil, email: 'foo@bar.com') }.to raise_error KeyError
            expect { described_class.create_attributes(nil, admin: true, roles: [], email: 'foo@bar.com') }.not_to raise_error
          end
          it 'accepts also strings as keys' do
            # Symbols were tested on the previous spec - testing strings here
            expect { described_class.create_attributes(nil, 'admin' => true, 'roles' => [], 'email' => 'foo@bar.com') }.not_to raise_error
          end
        end

        describe '::clean_roles' do
          let(:json_role) { {
            "sys": {
              "id": "foo",
              "type": "Link",
              "linkType": "Role"
            }
          } }

          let(:link_role) { Link.new(json_role, nil, client) }

          it 'returns the json representation of the roles wether they are a Link or a Hash' do
            expect(described_class.clean_roles([json_role, link_role])).to eq [json_role, json_role]
          end
        end
      end

      describe 'instance methods' do
        let(:membership) { described_class.new({
          "admin" => true,
          "roles" => [{
            "sys" => {
              "id" => "foo",
              "type" => "Link",
              "linkType" => "Role"
            }
          }]
        }) }

        describe '#roles' do
          it 'returns an array Link objects' do
            expect(membership.roles.first).to be_a Link
            expect(membership.roles.first.id).to eq 'foo'
          end
        end
      end

      describe '.all' do
        it 'returns a Contentful::Array' do
          vcr('space_memberships/all') { expect(subject.all).to be_kind_of Contentful::Management::Array }
        end

        it 'builds a Contentful::Management::SpaceMembership' do
          vcr('space_memberships/all') {
            memberships = subject.all

            admin_membership, normal_membership = memberships.items

            expect(admin_membership).to be_a Contentful::Management::SpaceMembership
            expect(admin_membership.admin).to eq true
            expect(admin_membership.roles).to eq []

            expect(normal_membership).to be_a Contentful::Management::SpaceMembership
            expect(normal_membership.admin).to eq false
            expect(normal_membership.roles.first).to be_a Link
          }
        end

        it 'class method also works' do
          vcr('space_memberships/all') { expect(Contentful::Management::SpaceMembership.all(client, space_id)).to be_kind_of Contentful::Management::Array }
        end
      end

      describe '.find' do
        it 'returns a Contentful::Management::SpaceMembership' do
          vcr('space_memberships/find') {
            membership = subject.find(membership_id)

            expect(membership).to be_a Contentful::Management::SpaceMembership
            expect(membership.admin).to eq false
            expect(membership.roles.first).to be_a Link
          }
        end
      end

      describe '.create' do
        it 'creates a Contentful::Management::SpaceMembership' do
          vcr('space_memberships/create') {
            membership = subject.create(
              admin: false,
              roles: [
                {
                  "sys" => {
                    "type" => "Link",
                    "linkType" => "Role",
                    "id" => "1Nq88dKTNXNaxkbrRpEEw6"
                  }
                }
              ],
              email: 'david.litvak+test_rcma@contentful.com'
            )

            expect(membership).to be_a Contentful::Management::SpaceMembership
            expect(membership.admin).to eq false
            expect(membership.roles.first).to be_a Link
          }
        end
      end

      describe '.find' do
        it 'finds a Contentful::Management::SpaceMembership' do
          vcr('space_memberships/find_2') {
            membership = subject.find(subject.all.first.id)
            expect(membership).to be_a Contentful::Management::SpaceMembership
          }
        end
      end

      describe '#destroy' do
        it 'deletes the membership' do
          vcr('space_memberships/delete') {
            membership = subject.find('7pcydolqtgMaSLwmXMvGqW')

            expect(membership.id).to be_truthy

            membership.destroy

            expect { subject.find('7pcydolqtgMaSLwmXMvGqW') }.to raise_error Contentful::Management::NotFound
          }
        end
      end
    end
  end
end
