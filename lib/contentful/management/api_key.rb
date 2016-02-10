require_relative 'resource'

module Contentful
  module Management
    # Resource class for ApiKey.
    # @see _ https://www.contentful.com/developers/docs/references/content-management-api/#/reference/api-keys
    class ApiKey
      include Contentful::Management::Resource
      include Contentful::Management::Resource::SystemProperties
      include Contentful::Management::Resource::Refresher

      property :name
      property :description
      property :accessToken
      property :policies

      # @private
      def self.create_attributes(_client, attributes)
        {
          'name' => attributes.fetch(:name),
          'description' => attributes.fetch(:description, nil)
        }
      end
    end
  end
end
