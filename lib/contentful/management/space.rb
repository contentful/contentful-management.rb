require_relative '../resource'
require_relative '../locale'
require_relative '../request'
require_relative 'content_type'

module Contentful
  module Management
    class Space

      include Contentful::Resource
      include Contentful::Resource::SystemProperties

      property :name, :string
      property :organization, :string
      property :locales, Locale

      def self.all
        request = Request.new('')
        response = request.get
        result = ResourceBuilder.new(self, response, {'Space' => Space}, {})
        result.run
      end

      def self.find(space_id)
        request = Request.new("/#{space_id}")
        response = request.get
        result = ResourceBuilder.new(self, response, {'Space' => Space}, {})
        result.run
      end

      def self.create(attributes)
        request = Request.new('', {'name' => attributes.fetch(:name)})
        response = request.post
        result = ResourceBuilder.new(self, response, {'Space' => Space}, {})
        result.run
      end

      def update(attributes)
        request = Request.new("/#{id}", {'name' => attributes.fetch(:name)}, nil, sys[:version])
        response = request.put
        result = ResourceBuilder.new(self, response, {'Space' => Space}, {})
        result.run
      end

      def save
        if id.present?
          update(name: name)
        else
          Space.create(name: name)
        end
      end

      def destroy
        request = Request.new("/#{id}")
        response = request.delete
        if response.status == :no_content
          return true
        else
          result = ResourceBuilder.new(self, response, {}, {})
          result.run
        end
      end

      def self.ContentType
        ContentType
      end

    end

  end
end
