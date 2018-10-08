require 'spec_helper'
require 'contentful/management/space'
require 'contentful/management/client'

module Contentful
  module Management
    describe UIExtension do
      let(:token) { ENV.fetch('CF_TEST_CMA_TOKEN', '<ACCESS_TOKEN>') }
      let(:space_id) { 'arqlnkt58eul' }
      let(:playground_space_id) { 'facgnwwgj5fe' }
      let(:extension_id) { '2ZJduY1pKEma6G8Y2ImqYU' }
      let(:client) { Client.new(token, raise_errors: true) }

      subject { client.ui_extensions(space_id, 'master') }

      describe 'class methods' do
        describe '::valid_extension?' do
          it 'false when name is missing' do
            extension = {}

            expect(described_class.valid_extension?(extension)).to be_falsey
          end

          it 'false when fieldTypes is missing' do
            extension = {
              'name' => 'foobar'
            }

            expect(described_class.valid_extension?(extension)).to be_falsey
          end

          it 'false when fieldTypes is present but not an array' do
            extension = {
              'name' => 'foobar',
              'fieldTypes' => 'baz'
            }

            expect(described_class.valid_extension?(extension)).to be_falsey
          end

          it 'false when both src and srcdoc missing' do
            extension = {
              'name' => 'foobar',
              'fieldTypes' => ['Symbol']
            }

            expect(described_class.valid_extension?(extension)).to be_falsey
          end

          it 'true when all of the above are passed' do
            extension = {
              'name' => 'foobar',
              'fieldTypes' => ['Symbol'],
              'src' => 'foo'
            }

            expect(described_class.valid_extension?(extension)).to be_truthy

            extension = {
              'name' => 'foobar',
              'fieldTypes' => ['Symbol'],
              'srcdoc' => 'foo'
            }

            expect(described_class.valid_extension?(extension)).to be_truthy
          end

          it 'false if sidebar is present but not boolean' do
            extension = {
              'name' => 'foobar',
              'fieldTypes' => ['Symbol'],
              'srcdoc' => 'foo',
              'sidebar' => true
            }

            expect(described_class.valid_extension?(extension)).to be_truthy

            extension = {
              'name' => 'foobar',
              'fieldTypes' => ['Symbol'],
              'srcdoc' => 'foo',
              'sidebar' => false
            }

            expect(described_class.valid_extension?(extension)).to be_truthy

            extension = {
              'name' => 'foobar',
              'fieldTypes' => ['Symbol'],
              'srcdoc' => 'foo',
              'sidebar' => 'foobar'
            }

            expect(described_class.valid_extension?(extension)).to be_falsey
          end
        end

        describe '::create_attributes' do
          it 'raises an error if extension sent is not valid' do
            invalid_extension = {
              extension: {
                'name' => 'foobar'
              }
            }

            expect do
              described_class.create_attributes(nil, invalid_extension)
            end.to raise_error 'Invalid UI Extension attributes'
          end

          it 'does nothing otherwise' do
            extension = {
              'extension' => {
                'name' => 'foobar',
                'fieldTypes' => ['Symbol'],
                'srcdoc' => 'foo',
                'sidebar' => false
              }
            }

            expect(described_class.create_attributes(nil, extension)).to eq extension
          end
        end
      end

      describe 'instance methods' do
        let(:extension) {
          described_class.new(
            'extension' => {
              'name' => 'foobar',
              'fieldTypes' => ['Symbol'],
              'srcdoc' => 'foo',
              'sidebar' => false
            }
          )
        }

        let(:src_extension) {
          described_class.new(
            'extension' => {
              'name' => 'foobar',
              'fieldTypes' => ['Symbol'],
              'src' => 'http://foo.com',
              'sidebar' => false
            }
          )
        }

        it '#name' do
          expect(extension.name).to eq 'foobar'
          extension.name = 'baz'

          expect(extension.name).to eq 'baz'
          expect(extension.extension['name']).to eq 'baz'
        end

        it '#field_types' do
          expect(extension.field_types).to eq ['Symbol']

          extension.field_types = ['Symbol', 'Text']

          expect(extension.field_types).to eq ['Symbol', 'Text']
          expect(extension.extension['fieldTypes']).to eq ['Symbol', 'Text']
        end

        describe '#source' do
          it 'will get first available source' do
            expect(extension.source).to eq 'foo'
            expect(src_extension.source).to eq 'http://foo.com'
          end

          it 'if source is a url will set it to src' do
            expect(extension.extension['srcdoc']).to eq 'foo'

            extension.source = 'http://example.com'

            expect(extension.extension['srcdoc']).to be_nil
            expect(extension.source).to eq 'http://example.com'
            expect(extension.extension['src']).to eq 'http://example.com'
          end

          it 'if source is a string will set it to srcdoc' do
            expect(src_extension.extension['src']).to eq 'http://foo.com'

            src_extension.source = 'foobar'

            expect(src_extension.extension['src']).to be_nil
            expect(src_extension.source).to eq 'foobar'
            expect(src_extension.extension['srcdoc']).to eq 'foobar'
          end
        end

        it '#sidebar' do
          expect(extension.sidebar).to eq false

          extension.sidebar = true

          expect(extension.sidebar).to eq true
          expect(extension.extension['sidebar']).to eq true
        end
      end

      describe '.all' do
        it 'returns a Contentful::Array' do
          vcr('ui_extension/all') { expect(subject.all).to be_kind_of Contentful::Management::Array }
        end

        it 'builds a Contentful::Management::UIExtension' do
          vcr('ui_extension/all') {
            extension = subject.all.first

            expect(extension).to be_kind_of Contentful::Management::UIExtension
            expect(extension.name).to eq 'My awesome extension by srcDoc'
            expect(extension.field_types).to eq [{"type"=>"Symbol"}, {"type"=>"Text"}]
            expect(extension.source).to eq "<!doctype html><html lang='en'><head><meta charset='UTF-8'/><title>Sample Editor Extension</title><link rel='stylesheet' href='https://contentful.github.io/ui-extensions-sdk/cf-extension.css'><script src='https://contentful.github.io/ui-extensions-sdk/cf-extension-api.js'></script></head><body><div id='content'></div><script>window.contentfulExtension.init(function (extension) {window.alert(extension);var value = extension.field.getValue();extension.field.setValue('Hello world!');extension.field.onValueChanged(function(value) {if (value !== currentValue) {extension.field.setValue('Hello world!');}});});</script></body></html>"
            expect(extension.sidebar).to eq false
            expect(extension.id).to be_truthy
          }
        end

        it 'class method also works' do
          vcr('ui_extension/all') { expect(Contentful::Management::UIExtension.all(client, space_id, 'master')).to be_kind_of Contentful::Management::Array }
        end
      end

      describe '.find' do
        it 'returns a Contentful::Management::UIExtension' do
          vcr('ui_extension/find') {
            extension = subject.find(extension_id)

            expect(extension).to be_kind_of Contentful::Management::UIExtension
            expect(extension.name).to eq 'My awesome extension by srcDoc'
            expect(extension.field_types).to eq [{"type"=>"Symbol"}, {"type"=>"Text"}]
            expect(extension.source).to eq "<!doctype html><html lang='en'><head><meta charset='UTF-8'/><title>Sample Editor Extension</title><link rel='stylesheet' href='https://contentful.github.io/ui-extensions-sdk/cf-extension.css'><script src='https://contentful.github.io/ui-extensions-sdk/cf-extension-api.js'></script></head><body><div id='content'></div><script>window.contentfulExtension.init(function (extension) {window.alert(extension);var value = extension.field.getValue();extension.field.setValue('Hello world!');extension.field.onValueChanged(function(value) {if (value !== currentValue) {extension.field.setValue('Hello world!');}});});</script></body></html>"
            expect(extension.sidebar).to eq false
            expect(extension.id).to be_truthy
          }
        end
      end

      describe '.create' do
        it 'creates a Contentful::Management::UIExtension' do
          vcr('ui_extension/create') {
            extension = client.ui_extensions(playground_space_id, 'master').create(extension: {
              'name' => 'test extension',
              'fieldTypes' => [{"type"=>"Symbol"}, {"type"=>"Text"}],
              'srcdoc' => "<!doctype html><html lang='en'><head><meta charset='UTF-8'/><title>Sample Editor Extension</title><link rel='stylesheet' href='https://contentful.github.io/ui-extensions-sdk/cf-extension.css'><script src='https://contentful.github.io/ui-extensions-sdk/cf-extension-api.js'></script></head><body><div id='content'></div><script>window.contentfulExtension.init(function (extension) {window.alert(extension);var value = extension.field.getValue();extension.field.setValue('Hello world!');extension.field.onValueChanged(function(value) {if (value !== currentValue) {extension.field.setValue('Hello world!');}});});</script></body></html>",
              'sidebar' => false
            })

            expect(extension).to be_kind_of Contentful::Management::UIExtension
            expect(extension.name).to eq 'test extension'
            expect(extension.field_types).to eq [{"type"=>"Symbol"}, {"type"=>"Text"}]
            expect(extension.source).to eq "<!doctype html><html lang='en'><head><meta charset='UTF-8'/><title>Sample Editor Extension</title><link rel='stylesheet' href='https://contentful.github.io/ui-extensions-sdk/cf-extension.css'><script src='https://contentful.github.io/ui-extensions-sdk/cf-extension-api.js'></script></head><body><div id='content'></div><script>window.contentfulExtension.init(function (extension) {window.alert(extension);var value = extension.field.getValue();extension.field.setValue('Hello world!');extension.field.onValueChanged(function(value) {if (value !== currentValue) {extension.field.setValue('Hello world!');}});});</script></body></html>"
            expect(extension.sidebar).to eq false
            expect(extension.id).to be_truthy
          }
        end

        it 'can customize ui extension parameters' do
          vcr('ui_extension/create_parameters') {
            extension = client.ui_extensions(playground_space_id, 'master').create(extension: {
              'name' => 'test extension with parameters',
              'fieldTypes' => [{"type"=>"Symbol"}, {"type"=>"Text"}],
              'srcdoc' => "<!doctype html><html lang='en'><head><meta charset='UTF-8'/><title>Sample Editor Extension</title><link rel='stylesheet' href='https://contentful.github.io/ui-extensions-sdk/cf-extension.css'><script src='https://contentful.github.io/ui-extensions-sdk/cf-extension-api.js'></script></head><body><div id='content'></div><script>window.contentfulExtension.init(function (extension) {window.alert(extension);var value = extension.field.getValue();extension.field.setValue('Hello world!');extension.field.onValueChanged(function(value) {if (value !== currentValue) {extension.field.setValue('Hello world!');}});});</script></body></html>",
              'sidebar' => false,
              'parameters' => {
                'installation' => [
                  {
                    'id' => 'devMode',
                    'type' => 'Boolean',
                    'name' => 'Run in development mode'
                  },
                  {
                    'id' => 'retries',
                    'type' => 'Number',
                    'name' => 'Number of retries for API calls',
                    'required' => true,
                    'default' => 3
                  }
                ],
                'instance' => [
                  {
                    'id' => 'helpText',
                    'type' => 'Symbol',
                    'name' => 'Help text',
                    'description' => 'Help text for a user to help them understand the editor'
                  },
                  {
                    'id' => 'theme',
                    'type' => 'Enum',
                    'name' => 'Theme',
                    'options' => [{'light' => 'Solarized light'}, {'dark' => 'Solarized dark'}],
                    'default' => 'light',
                    'required' => true
                  }
                ]
              }
            })

            expect(extension.parameters).to eq(
              'installation' => [
                {
                  'id' => 'devMode',
                  'type' => 'Boolean',
                  'name' => 'Run in development mode'
                },
                {
                  'id' => 'retries',
                  'type' => 'Number',
                  'name' => 'Number of retries for API calls',
                  'required' => true,
                  'default' => 3
                }
              ],
              'instance' => [
                {
                  'id' => 'helpText',
                  'type' => 'Symbol',
                  'name' => 'Help text',
                  'description' => 'Help text for a user to help them understand the editor'
                },
                {
                  'id' => 'theme',
                  'type' => 'Enum',
                  'name' => 'Theme',
                  'options' => [{'light' => 'Solarized light'}, {'dark' => 'Solarized dark'}],
                  'default' => 'light',
                  'required' => true
                }
              ]
            )
          }
        end
      end

      describe '#destroy' do
        it 'deletes the extension' do
          vcr('ui_extension/delete') {
            extension = client.ui_extensions(playground_space_id, 'master').find('2rf6QdckyoECCsQeE6gIOg')

            expect(extension.id).to be_truthy

            extension.destroy

            expect { client.ui_extensions(playground_space_id, 'master').find('2rf6QdckyoECCsQeE6gIOg') }.to raise_error Contentful::Management::NotFound
          }
        end
      end
    end
  end
end
