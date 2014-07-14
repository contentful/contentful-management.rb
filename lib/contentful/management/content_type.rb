require_relative '../resource'
require_relative 'field'

module Contentful
  module Management
    class ContentType

      include Contentful::Resource
      include Contentful::Resource::SystemProperties
      include Contentful::Resource::Refresher

      property :name, :string
      property :description, :string
      property :fields, Field
      property :displayField, :string

      def self.all(space_id)
        request = Request.new("/#{ space_id }/content_types")
        response = request.get
        result = ResourceBuilder.new(self, response, {}, {})
        result.run
      end

      def self.find(space_id, content_type_id)
        request = Request.new("/#{space_id}/content_types/#{ content_type_id }")
        response = request.get
        result = ResourceBuilder.new(self, response, {}, {})
        result.run
      end

      def destroy
        request = Request.new("/#{space.id}/content_types/#{id}")
        response = request.delete
        if response.status == :no_content
          return true
        else
          result = ResourceBuilder.new(self, response, {}, {})
          result.run
        end
      end

      def activate
        request = Request.new("/#{space.id}/content_types/#{id}/published", {}, nil, sys[:version])
        response = request.put
        result = ResourceBuilder.new(self, response, {}, {}).run
        if result.is_a? self.class
          refresh_data(result)
        else
          result
        end
      end

      def deactivate
        request = Request.new("/#{space.id}/content_types/#{id}/published")
        response = request.delete
        result = ResourceBuilder.new(self, response, {}, {}).run
        if result.is_a? self.class
          refresh_data(result)
        else
          result
        end
      end

      def active?
        !sys[:publishedAt].nil?
      end

      def self.create(space_id, attributes)
        fields = (attributes[:fields] || []).map(&:properties)
        request = Request.new("/#{space_id}/content_types/#{attributes[:id] || ''}", {'name' => attributes.fetch(:name), fields: fields})
        response = attributes[:id].nil? ? request.post : request.put
        result = ResourceBuilder.new(self, response, {}, {})
        result.run
      end

      def update(attributes)
        request = Request.new("/#{space.id}/content_types/#{id}", {'name' => attributes[:name]})
        response = request.put
        result = ResourceBuilder.new(self, response, {}, {})
        refresh_data(result.run)
      end

    end
  end
end
