require_relative 'resource'
require_relative 'validation'
module Contentful
  module Management
    # A ContentType's field schema
    class Field
      include Contentful::Management::Resource

      property :id, :string
      property :items, Field
      property :name, :string
      property :type, :string
      property :omitted, :boolean
      property :linkType, :string
      property :required, :boolean
      property :disabled, :boolean
      property :localized, :boolean
      property :validations, Validation

      # Takes a field object of content type
      # Merges existing properties, items and validations of field with new one
      # @private
      def deep_merge!(field)
        merge_properties(field.properties)
        merge_items(field.items)
        merge_validations(field.validations)
      end

      # Extract values of field to hash
      # @private
      def properties_to_hash
        properties.each_with_object({}) do |(key, value), results|
          results[key] = parse_value(key, value)
        end
      end

      # Return parsed value of field object
      # @private
      def parse_value(key, value)
        case key
        when :items
          value.properties_to_hash if type == 'Array' && value.is_a?(Field)
        when :validations
          validations_to_hash(value) if value.is_a?(::Array)
        else
          value if self.class.value_exists?(value)
        end
      end

      # @private
      def self.value_exists?(value)
        value.respond_to?(:empty?) && !value.empty? || !value.respond_to?(:empty?) && value
      end

      private

      # Update properties of field object
      def merge_properties(new_properties)
        properties.merge!(new_properties.select { |name, _type| name != :items && name != :validations })
      end

      # Update items of field object
      def merge_items(new_items)
        items.properties.merge!(new_items.properties) if items.respond_to?(:properties) && new_items.respond_to?(:properties)
      end

      # Takes an array with new validations
      # Returns merged existing and new validations
      def merge_validations(new_validations)
        return unless new_validations

        validations_by_type = validations_by_type(validations)
        new_validations_by_type = validations_by_type(new_validations)
        validations_by_type.delete_if { |type, _v| new_validations_by_type[type] }
        self.validations = validations_by_type.values + new_validations_by_type.values
      end

      def validations_by_type(validations)
        validations.is_a?(::Array) ? index_by_type(validations) : {}
      end

      # Build hash with validations
      def index_by_type(validations)
        validations.each_with_object({}) { |validation, results| results[validation.type] = validation }
      end

      def validations_to_hash(validations)
        validations.each_with_object([]) do |validation, results|
          results << validation.properties_to_hash
        end
      end
    end
  end
end
