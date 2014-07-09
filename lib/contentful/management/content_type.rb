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

      def self.all
        request = Request.new("/#{Thread.current[:space_id]}/content_types")
        response = request.get
        result = ResourceBuilder.new(self, response, {}, {})
        result.run
      end

    end
  end
end
