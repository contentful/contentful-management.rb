require 'spec_helper'
require 'contentful/management/space'
require 'contentful/management/client'

module Contentful
  module Management
    describe Locale do
      let(:token) { ENV.fetch('CF_TEST_CMA_TOKEN', '<ACCESS_TOKEN>') }
      let(:space_id) { 'n6spjc167pc2' }
      let(:locale_id) { '0X5xcjckv6RMrd9Trae81p' }

      let!(:client) { Client.new(token) }

      subject { client.locales(space_id, 'master') }

      describe '.all' do
        it 'class method also works' do
          vcr('locale/all_for_space') { expect(Contentful::Management::Locale.all(client, space_id, 'master')).to be_kind_of Contentful::Management::Array }
        end
        it 'returns a Contentful::Array' do
          vcr('locale/all_for_space') { expect(subject.all).to be_kind_of Contentful::Management::Array }
        end
        it 'builds a Contentful::Management::Locale object' do
          vcr('locale/all_for_space') { expect(subject.all.first).to be_kind_of Contentful::Management::Locale }
        end
      end

      describe '.find' do
        it 'class method also works' do
          vcr('locale/find') { expect(Contentful::Management::Locale.find(client, space_id, 'master', locale_id)).to be_kind_of Contentful::Management::Locale }
        end
        it 'returns a Contentful::Management::Locale' do
          vcr('locale/find') { expect(subject.find(locale_id)).to be_kind_of Contentful::Management::Locale }
        end
        it 'returns the locale for a given key' do
          vcr('locale/find') do
            locale = subject.find(locale_id)
            expect(locale.id).to eql locale_id
          end
        end
        it 'returns an error when content_type does not exists' do
          vcr('locale/find_for_space_not_found') do
            result = subject.find('not_exist')
            expect(result).to be_kind_of Contentful::Management::NotFound
          end
        end
      end
      describe '.create' do
        it 'create locales for space' do
          vcr('locale/create_for_space') do
            locale = subject.create(name: 'testLocalCreate', code: 'bg')
            expect(locale.name).to eql 'testLocalCreate'
          end
        end
      end

      describe '#reload' do
        let(:space_id) { 'bfsvtul0c41g' }
        it 'update the current version of the object to the version on the system' do
          vcr('locale/reload') do
            locale = subject.find('0ywTmGkjR0YhmbYaSmV1CS')
            locale.sys[:version] = 99
            locale.reload
            update_locale = locale.update(name: 'Polish PL')
            expect(update_locale).to be_kind_of Contentful::Management::Locale
            expect(locale.name).to eql 'Polish PL'
          end
        end
      end

      describe '#default' do
        it 'is false for non default' do
          vcr('locale/find_not_default') do
            locale = subject.find(locale_id)
            expect(locale.default).to be_falsey
          end
        end
        it 'is true for default' do
          vcr('locale/find_default') do
            locale = subject.find(locale_id)
            expect(locale.default).to be_truthy
          end
        end
      end

      describe '#optional' do
        let(:space_id) { 'n5kqlvx9cnp1' }
        it 'is false for non optional' do
          vcr('locale/find_not_optional') do
            locale_id = '56eOu5hJwVNb4XfqsnQV97'
            locale = subject.find(locale_id)
            expect(locale.optional).to be_falsey
          end
        end

        it 'is true for optional' do
          vcr('locale/find_optional') do
            locale_id = '7IHOkHoMY1PpFp1VSVlCpH'
            locale = subject.find(locale_id)
            expect(locale.optional).to be_truthy
          end
        end
      end

      describe '#update' do
        let!(:space_id) { 'bjwq7b86vgmm' }
        let!(:locale_id) { '63274yOrU0s4XiJlAp1ZMQ' }
        it 'can update the locale name' do
          vcr('locale/update_name') do
            locale = subject.find(locale_id)
            locale.update(name: 'Something')

            locale.reload

            expect(locale.name).to eq 'Something'
            expect(locale.code).to eq 'en-US'
          end
        end

        it 'can update the locale code' do
          vcr('locale/update_code') do
            locale = subject.find(locale_id)
            locale.update(code: 'es')

            locale.reload

            expect(locale.name).to eq 'U. S. English'
            expect(locale.code).to eq 'es'
          end
        end

        it 'can update both' do
          vcr('locale/update_both') do
            locale = subject.find(locale_id)
            locale.update(name: 'Spanish', code: 'es')

            locale.reload

            expect(locale.name).to eq 'Spanish'
            expect(locale.code).to eq 'es'
          end
        end

        describe '#destroy' do
          let!(:space_id) { 'bjwq7b86vgmm' }
          let!(:locale_id) { '63274yOrU0s4XiJlAp1ZMQ' }
          it 'can destroy locales' do
            vcr('locale/destroy') do
              locale = subject.create(name: 'Spanish (Argentina)', code: 'es-AR')

              expect(subject.find(locale.id).code).to eq 'es-AR'

              locale.destroy

              error = subject.find(locale.id)

              expect(error).to be_a Contentful::Management::NotFound
            end
          end
        end
      end

      describe 'issues' do
        let!(:space_id) { 'facgnwwgj5fe' }
        it 'should be able to create a locale with a fallback code' do
          vcr('locale/fallback_code') do
            locale = subject.create(name: 'Foo (BarBaz)', code: 'foo-BB', fallback_code: 'en-US')

            expect(subject.find(locale.id).code).to eq 'foo-BB'
          end
        end
      end
    end
  end
end
