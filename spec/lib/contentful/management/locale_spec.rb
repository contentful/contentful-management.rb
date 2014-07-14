require 'spec_helper'
require 'contentful/management/space'
require 'contentful/management/client'

module Contentful
  module Management
    describe Locale do
      let(:token) { '51cb89f45412ada2be4361599a96d6245e19913b6d2575eaf89dafaf99a443aa' }
      let(:space_id) { 'n6spjc167pc2' }
      let(:locale_id) { '0X5xcjckv6RMrd9Trae81p' }

      let!(:client) { Client.new(token) }

      subject { Contentful::Management::Locale }

      describe '.all' do
        it 'returns a Contentful::Array' do
          vcr(:get_locales_for_space) { expect(subject.all(space_id)).to be_kind_of Contentful::Array }
        end
        it 'builds a Contentful::Management::Locale object' do
          vcr(:get_locales_for_space) { expect(subject.all(space_id).first).to be_kind_of Contentful::Management::Locale }
        end
      end

      describe '.find' do
        it 'returns a Contentful::Management::Locale' do
          vcr(:get_locale) { expect(subject.find(space_id, locale_id)).to be_kind_of Contentful::Management::Locale }
        end
        it 'returns the locale for a given key' do
          vcr(:get_locale) do
            locale = subject.find(space_id, locale_id)
            expect(locale.id).to eql locale_id
          end
        end
        it 'returns an error when content_type does not exists' do
          vcr(:locale_not_found_for_space) do
            result = subject.find(space_id, 'not_exist')
            expect(result).to be_kind_of Contentful::NotFound
          end
        end
      end
      describe '.create' do
        it 'create locales for space' do
          vcr(:locale_create_for_space) do
            locale = subject.create(space_id, name: 'testLocalCreate', code: 'bg')
            expect(locale.name).to eql 'testLocalCreate'
          end
        end
      end
    end
  end
end