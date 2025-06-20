require 'spec_helper'
require 'contentful/management/space'
require 'contentful/management/client'

module Contentful
  module Management
    describe EditorInterface do
      let(:token) { ENV.fetch('CF_TEST_CMA_TOKEN', '<ACCESS_TOKEN>') }
      let(:space_id) { 'oe3b689om6k5' }
      let(:content_type_id) { 'testInterfaces' }
      let(:editor_interface_id) { 'default' }

      let(:editor_interface_attrs) {
        {
          controls: [
            {
              'fieldId' => 'symbol1',
              'widgetId' => 'urlEditor'
            }
          ]
        }
      }

      let!(:client) { Client.new(token) }

      subject { client.editor_interfaces(space_id, 'master', content_type_id) }

      describe '.all' do
        it 'class method also works' do
          vcr('editor_interfaces/all') { expect(Contentful::Management::EditorInterface.all(client, space_id, 'master')).to be_kind_of Contentful::Management::Array }
        end
        it 'builds a Contentful::Management::Entry object' do
          vcr('editor_interfaces/all') { expect(Contentful::Management::EditorInterface.all(client, space_id, 'master').first).to be_kind_of Contentful::Management::EditorInterface }
        end
      end

      describe '.default' do
        it 'class method also works' do
          vcr('editor_interfaces/default_for_space') { expect(Contentful::Management::EditorInterface.default(client, space_id, 'master', content_type_id)).to be_kind_of Contentful::Management::EditorInterface }
        end
        it 'builds a Contentful::Management::Locale object' do
          vcr('editor_interfaces/default_for_space') { expect(subject.default).to be_kind_of Contentful::Management::EditorInterface }
        end
      end

      describe '#update' do
        let(:content_type_id) { 'smallerType' }

        it 'can update the editor_interface' do
          vcr('editor_interfaces/update') do
            editor_interface = described_class.default(client, space_id, 'master', content_type_id)

            expect(editor_interface.controls.first['widgetId']).to eq 'singleline'

            editor_interface.controls.first['widgetId'] = 'urlEditor'
            editor_interface.update(controls: editor_interface.controls)

            editor_interface.reload

            expect(editor_interface.controls.first['widgetId']).to eq 'urlEditor'
          end
        end

        it 'can update the sidebar' do
          vcr('editor_interfaces/update_sidebar') do
            editor_interface = described_class.default(client, space_id, 'master', content_type_id)

            expect(editor_interface.sidebar.first['widgetId']).to eq 'flow-editor'

            editor_interface.sidebar.first['widgetId'] = 'date-range-editor'
            editor_interface.update(sidebar: editor_interface.sidebar)

            editor_interface.reload

            expect(editor_interface.sidebar.first['widgetId']).to eq 'date-range-editor'
          end
        end
      end

      describe '#save' do
        let(:content_type_id) { 'smallerType' }

        it 'can update the editor_interface - a shortcut to #update(controls: editor_interface.controls)' do
          vcr('editor_interfaces/update') do
            editor_interface = described_class.default(client, space_id, 'master', content_type_id)

            expect(editor_interface.controls.first['widgetId']).to eq 'singleline'

            editor_interface.controls.first['widgetId'] = 'urlEditor'
            editor_interface.save

            editor_interface.reload

            expect(editor_interface.controls.first['widgetId']).to eq 'urlEditor'
          end
        end

        it 'can save sidebar' do
          vcr('editor_interfaces/update_sidebar') do
            editor_interface = described_class.default(client, space_id, 'master', content_type_id)

            expect(editor_interface.sidebar.first['widgetId']).to eq 'flow-editor'

            editor_interface.sidebar.first['widgetId'] = 'date-range-editor'
            editor_interface.save

            editor_interface.reload

            expect(editor_interface.sidebar.first['widgetId']).to eq 'date-range-editor'
          end
        end
      end
    end
  end
end
