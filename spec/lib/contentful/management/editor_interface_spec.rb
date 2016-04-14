require 'spec_helper'
require 'contentful/management/space'
require 'contentful/management/client'

module Contentful
  module Management
    describe EditorInterface do
      let(:token) { '<ACCESS_TOKEN>' }
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

      subject { client.editor_interfaces }

      describe '.default' do
        it 'class method also works' do
          vcr('editor_interfaces/default_for_space') { expect(Contentful::Management::EditorInterface.default(client, space_id, content_type_id)).to be_kind_of Contentful::Management::EditorInterface }
        end
        it 'builds a Contentful::Management::Locale object' do
          vcr('editor_interfaces/default_for_space') { expect(subject.default(space_id, content_type_id)).to be_kind_of Contentful::Management::EditorInterface }
        end
      end

      describe '.find' do
        it 'class method also works' do
          vcr('editor_interfaces/find') { expect(Contentful::Management::EditorInterface.find(client, space_id, content_type_id, editor_interface_id)).to be_kind_of Contentful::Management::EditorInterface }
        end
        it 'returns a Contentful::Management::EditorInterface' do
          vcr('editor_interfaces/find') { expect(subject.find(space_id, content_type_id, editor_interface_id)).to be_kind_of Contentful::Management::EditorInterface }
        end
      end

      describe '.create' do
        let(:content_type_id) { 'smallerType' }

        it 'create editor_interface for space' do
          vcr('editor_interfaces/create_for_space') do
            editor_interface = subject.create(space_id, content_type_id, 'someId', editor_interface_attrs)

            expect(editor_interface.controls.first).to eq('fieldId' => 'symbol1', 'widgetId' => 'urlEditor')
          end
        end
      end
      describe '#update' do
        let(:content_type_id) { 'smallerType' }

        it 'can update the editor_interface' do
          vcr('editor_interfaces/update') do
            editor_interface = subject.default(space_id, content_type_id)

            expect(editor_interface.controls.first['widgetId']).to eq 'singleLine'

            editor_interface.controls.first['widgetId'] = 'urlEditor'
            editor_interface.update(controls: editor_interface.controls)

            editor_interface.reload

            expect(editor_interface.controls.first['widgetId']).to eq 'urlEditor'
          end
        end
      end
    end
  end
end
