require 'spec_helper'
require 'contentful/management/client'

module Contentful
  module Management
    describe ContentTypeClient do
      let(:token) { 'such_a_long_token' }
      let(:space_id) { 'xxddi16swo35' }
      let(:content_type_id) { '18cchFmtwGYS0uuQeG08E4' }
      # let(:space_id) { 'uyvxw082vcxv' }
      # let(:token) { '005d6f51203bcae1fa9b44d92d810f2ca32337c3559857eacfedc65cee4d7a3c' }
      let(:client) { Client.new(token) }

      subject { client }

      describe '#content_type' do
        it 'returns a Contentful::ContentType' do
          vcr(:get_content_type) do
            expect(client.content_type(space_id, content_type_id)).to be_kind_of Contentful::ContentType
          end
        end

        it 'returns a content type for a given space_id and content_type_id' do
          vcr(:get_content_type) do
            content_type = client.content_type(space_id, content_type_id)
            expect(content_type.id).to eq content_type_id
          end
        end
      end

      describe '#content_types' do
        it 'returns a Contentful::Array' do
          vcr(:get_content_types) do
            expect(client.content_types(space_id)).to be_kind_of Contentful::Array
          end
        end

        it 'builds a Contentful::ContentType object' do
          vcr(:get_content_types) do
            expect(client.content_types(space_id).first).to be_kind_of Contentful::ContentType
          end
        end
      end
    end
  end
end
