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

      def properties_for_update
        @properties.select {|k, _v| k != :items}
      end

    end
  end
end
