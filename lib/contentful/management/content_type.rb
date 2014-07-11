require_relative '../resource'
require_relative '../field'

module Contentful

  module Management

    class ContentType
      include Contentful::Resource
      include Contentful::Resource::SystemProperties

      property :name, :string
      property :description, :string
      property :fields, Field
      property :displayField, :string

      def self.all(space_id)
        request = Request.new("/#{space_id}/content_types")
        response = request.get
        result = ResourceBuilder.new(self, response, {}, {})
        result.run
      end

      def self.find(space_id, content_type_id)
        request = Request.new("/#{space_id}/content_types/#{content_type_id}")
        response = request.get
        result = ResourceBuilder.new(self, response, {}, {})
        result.run
      end

      def self.create(space_id, attributes)
        #TODO add implememntation
        request = Request.new('', {'name' => attributes.fetch(:name)}, nil, nil, attributes[:organization_id])
        response = request.post
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

    end
  end
end
