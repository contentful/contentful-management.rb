# -*- encoding: utf-8 -*-
require_relative 'resource'

module Contentful
  module Management
    # A ContentType's field schema
    class Field
      include Contentful::Management::Resource

      property :id, :string
      property :name, :string
      property :type, :string
      property :linkType, :string
      property :items, Field
      property :required, :boolean
      property :localized, :boolean

      def deep_merge!(field)
        properties.merge!(field.properties.select { |name, _type| name != :items })
        items.properties.merge!(field.items.properties) if (items.respond_to?(:properties) && field.items.respond_to?(:properties))
      end

      def properties_to_hash
        properties.each_with_object({}) do |(key, value), results|
          if key == :items
            results[key] = value.properties_to_hash if type == 'Array' && value.is_a?(Field)
          else
            results[key] = value if !value.nil? && (value.respond_to?(:empty?) && !value.empty? || !value.respond_to?(:empty?) && value)
          end
        end
      end
    end
  end
end
