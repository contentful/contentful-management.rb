require 'spec_helper'

describe Contentful::Management::Environment do
  let(:token) { ENV.fetch('CF_TEST_CMA_TOKEN', '<ACCESS_TOKEN>') }
  let(:client) { ::Contentful::Management::Client.new(token, raise_errors: true) }
  let(:space_id) { 'facgnwwgj5fe' }
  let(:master) { 'master' }
  let(:testing) { 'testing' }

  subject { client.environments(space_id) }

  describe '.all' do
    it 'fetches all environments for a space' do
      vcr('environment/all') {
        environments = subject.all

        expect(environments.size).to eq 2
        expect(environments.first).to be_a ::Contentful::Management::Environment
      }
    end

    it 'class method also works' do
      vcr('environment/all') {
        environments = described_class.all(client, space_id)

        expect(environments.size).to eq 2
        expect(environments.first).to be_a ::Contentful::Management::Environment
      }
    end
  end

  describe '.find' do
    it 'fetches an environment by id' do
      vcr('environment/find') {
        environment = subject.find(testing)

        expect(environment.id).to eq testing
        expect(environment.name).to eq 'testing'
      }
    end

    it 'class method also works' do
      vcr('environment/find') {
        environment = described_class.find(client, space_id, testing)

        expect(environment.id).to eq testing
        expect(environment.name).to eq 'testing'
      }
    end
  end

  describe '.create' do
    it 'can create an environment' do
      vcr('environment/create') {
        environment = subject.create(id: 'delete_me', name: 'Delete Me')

        expect(environment.id).to eq 'delete_me'
        expect(environment.name).to eq 'Delete Me'
      }
    end

    it 'class method also works' do
      vcr('environment/create') {
        environment = described_class.create(client, space_id, id: 'delete_me', name: 'Delete Me')

        expect(environment.id).to eq 'delete_me'
        expect(environment.name).to eq 'Delete Me'
      }
    end
  end

  describe '#destroy' do
    it 'deletes an environment' do
      vcr('environment/find_2') {
        environment = subject.find('delete_me')

        vcr('environment/destroy') {
          environment.destroy
        }

        vcr('environment/not_found') {
          expect { subject.find('delete_me') }.to raise_error ::Contentful::Management::NotFound
        }
      }
    end
  end

  describe 'proxies' do
    it 'entries proxy works' do
      vcr('environment/entry_proxy') {
        environment = subject.find(master)

        entries = environment.entries.all
        expect(entries).to be_a ::Contentful::Management::Array

        entry = environment.entries.find(entries.first.id)
        expect(entry).to be_a ::Contentful::Management::Entry
      }
    end
  end

  describe '#reload' do
    it 'can reload' do
      vcr('environment/find') {
        environment = subject.find(testing)

        vcr('environment/find_3') {
          expect { environment.reload }.not_to raise_exception
        }
      }
    end
  end
end
