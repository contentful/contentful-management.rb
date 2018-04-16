require 'spec_helper'
require 'contentful/management/space'
require 'contentful/management/client'

module Contentful
  module Management
    describe Role do
      let(:token) { '<ACCESS_TOKEN>' }
      let(:space_id) { '03vrieuz7eun' }
      let(:role_id) { '0rQMQMd6ZTgeF7hxjz7JDi' }

      let(:role_attrs) {
        {
          name: 'testRoleCreate',
          description: 'test role',
          permissions: {
            'ContentDelivery' => 'all',
            'ContentModel' => ['read'],
            'Settings' => []
          },
          policies: [
            {
              effect: 'allow',
              actions: 'all',
              constraint: {
                and: [
                  {
                    equals: [
                      { doc: 'sys.type' },
                      'Entry'
                    ]
                  },
                  {
                    equals: [
                      { doc: 'sys.type' },
                      'Asset'
                    ]
                  }
                ]
              }
            }
          ]
        }
      }

      let!(:client) { Client.new(token) }

      subject { client.roles(space_id) }

      describe '.all' do
        it 'class method also works' do
          vcr('roles/all_for_space') { expect(Contentful::Management::Role.all(client, space_id)).to be_kind_of Contentful::Management::Array }
        end
        it 'returns a Contentful::Array' do
          vcr('roles/all_for_space') { expect(subject.all).to be_kind_of Contentful::Management::Array }
        end
        it 'builds a Contentful::Management::Locale object' do
          vcr('roles/all_for_space') { expect(subject.all.first).to be_kind_of Contentful::Management::Role }
        end
      end

      describe '.find' do
        it 'class method also works' do
          vcr('roles/find') { expect(Contentful::Management::Role.find(client, space_id, role_id)).to be_kind_of Contentful::Management::Role }
        end
        it 'returns a Contentful::Management::Role' do
          vcr('roles/find') { expect(subject.find(role_id)).to be_kind_of Contentful::Management::Role }
        end
        it 'returns the locale for a given key' do
          vcr('roles/find') do
            role = subject.find(role_id)
            expect(role.id).to eq role_id
          end
        end
        it 'returns an error when content_type does not exists' do
          vcr('roles/find_for_space_not_found') do
            result = subject.find('not_exist')
            expect(result).to be_kind_of Contentful::Management::NotFound
          end
        end
      end
      describe '.create' do
        it 'create role for space' do
          vcr('roles/create_for_space') do
            role = subject.create(role_attrs)

            expect(role.name).to eq 'testRoleCreate'
            expect(role.description).to eq 'test role'
            expect(role.permissions['ContentDelivery']).to eq 'all'
            expect(role.policies.first['effect']).to eq 'allow'
          end
        end
      end
      describe '#update' do
        it 'can update the role' do
          vcr('roles/update') do
            role = subject.find(role_id)
            role.update(name: 'Something')

            role.reload

            expect(role.name).to eq 'Something'
          end
        end
      end

      describe '#destroy' do
        it 'can destroy roles' do
          vcr('roles/destroy') do
            role_attrs[:name] = 'ToDelete'
            role = subject.create(role_attrs)

            expect(subject.find(role.id).name).to eq 'ToDelete'

            role.destroy

            error = subject.find(role.id)

            expect(error).to be_a Contentful::Management::NotFound
          end
        end
      end
    end
  end
end
