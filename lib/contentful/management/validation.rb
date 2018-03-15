require_relative 'resource'

module Contentful
  module Management
    # A ContentType's validations schema
    class Validation
      include Contentful::Management::Resource

      property :in, :array
      property :size, :hash
      property :range, :hash
      property :regexp, :hash
      property :unique, :boolean
      property :present, :boolean
      property :linkField, :boolean
      property :assetFileSize, :hash
      property :linkContentType, :array
      property :linkMimetypeGroup, :string
      property :assetImageDimensions, :hash

      # @private
      def properties_to_hash
        properties.each_with_object({}) do |(key, value), results|
          results[key] = value if Field.value_exists?(value)
        end
      end

      # Returns type of validation
      # @return [Symbol]
      def type
        properties.keys.reject { |key| key == :validations }.each do |type|
          value = send(Support.snakify(type))
          return type if !value.nil? && value
        end
      end
    end
  end
end
