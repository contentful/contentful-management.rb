require_relative '../resource'

module Contentful
  module Management
    class Field
      include Contentful::Resource

      property :id, :string
      property :name, :string
      property :type, :string
      property :items, Field
      property :required, :boolean
      property :localized, :boolean

      def update_properties
        @properties.delete(:items)
        @properties
      end
    end
  end
end
