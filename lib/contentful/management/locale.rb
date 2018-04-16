require_relative 'resource'
require_relative 'resource/environment_aware'

module Contentful
  module Management
    # Resource class for Locale.
    class Locale
      include Contentful::Management::Resource
      include Contentful::Management::Resource::SystemProperties
      include Contentful::Management::Resource::Refresher
      include Contentful::Management::Resource::EnvironmentAware

      property :code, :string
      property :name, :string
      property :publish, :boolean
      property :default, :boolean
      property :optional, :boolean
      property :fallbackCode, :string
      property :contentDeliveryApi, :boolean
      property :contentManagementApi, :boolean

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
