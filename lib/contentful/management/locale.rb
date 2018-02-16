require_relative 'resource'

module Contentful
  module Management
    # Resource class for Locale.
    class Locale
      include Contentful::Management::Resource
      include Contentful::Management::Resource::SystemProperties
      include Contentful::Management::Resource::Refresher

      property :code, :string
      property :name, :string
      property :contentManagementApi, :boolean
      property :contentDeliveryApi, :boolean
      property :publish, :boolean
      property :default, :boolean
      property :optional, :boolean
      property :fallbackCode, :string

      # @private
      def self.create_attributes(_client, attributes)
        {
          'name' => attributes.fetch(:name),
          'code' => attributes.fetch(:code),
          'optional' => attributes.fetch(:optional, false),
          'fallbackCode' => attributes.fetch(:fallback_code, nil)
        }
      end

      protected

      def query_attributes(attributes)
        attributes.each_with_object({}) { |(k, v), result| result[k.to_sym] = v }
      end
    end
  end
end
