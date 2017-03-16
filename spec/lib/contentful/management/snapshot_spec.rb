require 'spec_helper'
require 'contentful/management/space'
require 'contentful/management/client'

module Contentful
  module Management
    describe Snapshot do
      let(:token) { '<ACCESS_TOKEN>' }
      let(:space_id) { 'facgnwwgj5fe' }
      let(:entry_id) { '5gQdVmPHKwIk2MumquYwOu' }
      let(:snapshot_id) { '6DglRQMMHWUnzi2F3RjFFo' }
      let!(:client) { Client.new(token) }

      subject { client.snapshots }

      describe '.all' do
        it 'class method also works' do
          vcr('snapshot/all') { expect(Contentful::Management::Snapshot.all(client, space_id, entry_id)).to be_kind_of Contentful::Management::Array }
        end
        it 'returns a Contentful::Array' do
          vcr('snapshot/all') { expect(subject.all(space_id, entry_id)).to be_kind_of Contentful::Management::Array }
        end
        it 'builds a Contentful::Management::Snapshot object' do
          vcr('snapshot/all') { expect(subject.all(space_id, entry_id).first).to be_kind_of Contentful::Management::Snapshot }
        end
      end

      describe '.find' do
        it 'class method also works' do
          vcr('snapshot/find') { expect(Contentful::Management::Snapshot.find(client, space_id, entry_id, snapshot_id)).to be_kind_of Contentful::Management::Snapshot }
        end
        it 'returns a Contentful::Management::Snapshot' do
          vcr('snapshot/find') { expect(subject.find(space_id, entry_id, snapshot_id)).to be_kind_of Contentful::Management::Snapshot }
        end
        it 'returns snapshot for a given key' do
          vcr('snapshot/find') do
            snapshot = subject.find(space_id, entry_id, snapshot_id)
            expect(snapshot.id).to eql snapshot_id
          end
        end
        it 'returns an error when snapshot does not exist' do
          vcr('snapshot/find_not_found') do
            result = subject.find(space_id, entry_id, 'not_exist')
            expect(result).to be_kind_of Contentful::Management::NotFound
          end
        end
      end

      describe '.create' do
        it 'is not supported' do
          expect { subject.create }.to raise_error 'Not supported'
        end
      end

      describe '#update' do
        it 'is not supported' do
          vcr('snapshot/find') do
            snapshot = subject.find(space_id, entry_id, snapshot_id)

            expect { snapshot.update }.to raise_error 'Not supported'
          end
        end
      end

      describe '#destroy' do
        it 'is not supported' do
          vcr('snapshot/find') do
            snapshot = subject.find(space_id, entry_id, snapshot_id)

            expect { snapshot.destroy }.to raise_error 'Not supported'
          end
        end
      end

      describe 'properties' do
        it '.snapshot' do
          vcr('snapshot/properties') do
            snapshot = subject.find(space_id, entry_id, snapshot_id)

            expect(snapshot.snapshot).to be_a Contentful::Management::Entry
            expect(snapshot.snapshot.name['en-US']).to eq 'something else'
          end
        end
      end
    end
  end
end
