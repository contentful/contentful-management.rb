require 'spec_helper'
require 'contentful/management/space'
require 'contentful/management/client'

module Contentful
  module Management
    describe Snapshot do
      let(:token) { ENV.fetch('CF_TEST_CMA_TOKEN', '<ACCESS_TOKEN>') }
      let(:space_id) { 'facgnwwgj5fe' }
      let(:entry_id) { '5gQdVmPHKwIk2MumquYwOu' }
      let(:content_type_id) { 'cat' }
      let(:snapshot_id) { '6DglRQMMHWUnzi2F3RjFFo' }
      let(:ct_snapshot_id) { '5bfy52PVk8HwBfXURLOsWJ' }
      let!(:client) { Client.new(token) }

      describe 'default behaviour is entry snapshots' do
        subject { client.snapshots(space_id, 'master') }

        describe '.all' do
          it 'class method also works' do
            vcr('snapshot/all') { expect(Contentful::Management::Snapshot.all(client, space_id, 'master', entry_id)).to be_kind_of Contentful::Management::Array }
          end
          it 'returns a Contentful::Array' do
            vcr('snapshot/all') { expect(subject.all(entry_id)).to be_kind_of Contentful::Management::Array }
          end
          it 'builds a Contentful::Management::Snapshot object' do
            vcr('snapshot/all') { expect(subject.all(entry_id).first).to be_kind_of Contentful::Management::Snapshot }
          end
        end

        describe '.find' do
          it 'class method also works' do
            vcr('snapshot/find') { expect(Contentful::Management::Snapshot.find(client, space_id, 'master', entry_id, snapshot_id)).to be_kind_of Contentful::Management::Snapshot }
          end
          it 'returns a Contentful::Management::Snapshot' do
            vcr('snapshot/find') { expect(subject.find(entry_id, snapshot_id)).to be_kind_of Contentful::Management::Snapshot }
          end
          it 'returns snapshot for a given key' do
            vcr('snapshot/find') do
              snapshot = subject.find(entry_id, snapshot_id)
              expect(snapshot.id).to eql snapshot_id
            end
          end
          it 'returns an error when snapshot does not exist' do
            vcr('snapshot/find_not_found') do
              result = subject.find(entry_id, 'not_exist')
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
              snapshot = subject.find(entry_id, snapshot_id)

              expect { snapshot.update }.to raise_error 'Not supported'
            end
          end
        end

        describe '#destroy' do
          it 'is not supported' do
            vcr('snapshot/find') do
              snapshot = subject.find(entry_id, snapshot_id)

              expect { snapshot.destroy }.to raise_error 'Not supported'
            end
          end
        end

        describe 'properties' do
          it '.snapshot' do
            vcr('snapshot/properties') do
              snapshot = subject.find(entry_id, snapshot_id)

              expect(snapshot.snapshot).to be_a Contentful::Management::Entry
              expect(snapshot.snapshot.name['en-US']).to eq 'something else'
            end
          end
        end
      end

      describe 'entry snapshots' do
        subject { client.entry_snapshots(space_id, 'master') }

        describe '.all' do
          it 'class method also works' do
            vcr('snapshot/all') { expect(Contentful::Management::Snapshot.all(client, space_id, 'master', entry_id)).to be_kind_of Contentful::Management::Array }
          end
          it 'returns a Contentful::Array' do
            vcr('snapshot/all') { expect(subject.all(entry_id)).to be_kind_of Contentful::Management::Array }
          end
          it 'builds a Contentful::Management::Snapshot object' do
            vcr('snapshot/all') {
              snapshot = subject.all(entry_id).first
              expect(snapshot).to be_kind_of Contentful::Management::Snapshot
              expect(snapshot.snapshot).to be_kind_of Contentful::Management::DynamicEntry
            }
          end
        end

        describe '.find' do
          it 'class method also works' do
            vcr('snapshot/find') { expect(Contentful::Management::Snapshot.find(client, space_id, 'master', entry_id, snapshot_id)).to be_kind_of Contentful::Management::Snapshot }
          end
          it 'returns a Contentful::Management::Snapshot' do
            vcr('snapshot/find') { expect(subject.find(entry_id, snapshot_id)).to be_kind_of Contentful::Management::Snapshot }
          end
          it 'returns snapshot for a given key' do
            vcr('snapshot/find') do
              snapshot = subject.find(entry_id, snapshot_id)
              expect(snapshot.id).to eql snapshot_id
            end
          end
          it 'returns an error when snapshot does not exist' do
            vcr('snapshot/find_not_found') do
              result = subject.find(entry_id, 'not_exist')
              expect(result).to be_kind_of Contentful::Management::NotFound
            end
          end
        end
      end

      describe 'describe content type snapshots' do
        subject { client.content_type_snapshots(space_id, 'master') }

        describe '.all' do
          it 'class method also works' do
            vcr('snapshot/ct_all') { expect(Contentful::Management::Snapshot.all(client, space_id, 'master', content_type_id, 'content_types')).to be_kind_of Contentful::Management::Array }
          end
          it 'returns a Contentful::Array' do
            vcr('snapshot/ct_all') { expect(subject.all(content_type_id)).to be_kind_of Contentful::Management::Array }
          end
          it 'builds a Contentful::Management::Snapshot object' do
            vcr('snapshot/ct_all') {
              snapshot = subject.all(content_type_id).first
              expect(snapshot).to be_kind_of Contentful::Management::Snapshot
              expect(snapshot.snapshot).to be_kind_of Contentful::Management::ContentType
            }
          end
        end

        describe '.find' do
          it 'class method also works' do
            vcr('snapshot/ct_find') { expect(Contentful::Management::Snapshot.find(client, space_id, 'master', content_type_id, ct_snapshot_id, 'content_types')).to be_kind_of Contentful::Management::Snapshot }
          end
          it 'returns a Contentful::Management::Snapshot' do
            vcr('snapshot/ct_find') { expect(subject.find(content_type_id, ct_snapshot_id)).to be_kind_of Contentful::Management::Snapshot }
          end
          it 'returns snapshot for a given key' do
            vcr('snapshot/ct_find') do
              snapshot = subject.find(content_type_id, ct_snapshot_id)
              expect(snapshot.id).to eql ct_snapshot_id
              expect(snapshot.snapshot.id).to eq content_type_id
            end
          end
          it 'returns an error when snapshot does not exist' do
            vcr('snapshot/ct_find_not_found') do
              result = subject.find(content_type_id, 'not_exist')
              expect(result).to be_kind_of Contentful::Management::NotFound
            end
          end
        end
      end
    end
  end
end
