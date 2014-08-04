# -*- encoding: utf-8 -*-
require 'spec_helper'
require 'contentful/management/space'
require 'contentful/management/client'

module Contentful
  module Management
    describe Locale do
      let(:token) { '<ACCESS_TOKEN>' }
      let(:space_id) { 'n6spjc167pc2' }
      let(:locale_id) { '0X5xcjckv6RMrd9Trae81p' }

      let!(:client) { Client.new(token) }

      subject { Contentful::Management::Locale }

      describe '.all' do
        it 'returns a Contentful::Array' do
          vcr('locale/all_for_space') { expect(subject.all(space_id)).to be_kind_of Contentful::Management::Array }
        end
        it 'builds a Contentful::Management::Locale object' do
          vcr('locale/all_for_space') { expect(subject.all(space_id).first).to be_kind_of Contentful::Management::Locale }
        end
      end

      describe '.find' do
        it 'returns a Contentful::Management::Locale' do
          vcr('locale/find') { expect(subject.find(space_id, locale_id)).to be_kind_of Contentful::Management::Locale }
        end
        it 'returns the locale for a given key' do
          vcr('locale/find') do
            locale = subject.find(space_id, locale_id)
            expect(locale.id).to eql locale_id
          end
        end
        it 'returns an error when content_type does not exists' do
          vcr('locale/find_for_space_not_found') do
            result = subject.find(space_id, 'not_exist')
            expect(result).to be_kind_of Contentful::Management::NotFound
          end
        end
      end
      describe '.create' do
        it 'create locales for space' do
          vcr('locale/create_for_space') do
            locale = subject.create(space_id, name: 'testLocalCreate', code: 'bg')
            expect(locale.name).to eql 'testLocalCreate'
          end
        end
      end
    end
  end
end
