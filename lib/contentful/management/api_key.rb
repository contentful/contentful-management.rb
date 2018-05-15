require_relative 'resource'

module Contentful
  module Management
    # Resource class for ApiKey.
    # @see _ https://www.contentful.com/developers/docs/references/content-management-api/#/reference/api-keys
    class ApiKey
      include Contentful::Management::Resource
      include Contentful::Management::Resource::Refresher
      include Contentful::Management::Resource::SystemProperties

      property :name
      property :policies
      property :description
      property :accessToken
      property :environments
      property :preview_api_key, Link

      # @private
      def self.create_attributes(_client, attributes)
        {
          'name' => attributes.fetch(:name),
          'description' => attributes.fetch(:description, nil),
          'environments' => attributes.fetch(:environments, []) # Will default to master if empty
        }
      end

      # Creates an API Key.
      #
      # @param [Contentful::Management::Client] client
      # @param [String] space_id
      # @param [Hash] attributes
      # @see _ README for full attribute list for each resource.
      #
      # @return [Contentful::Management::ApiKey]
      def self.create(client, space_id, attributes = {})
        super(client, space_id, nil, attributes)
      end

      # Finds an API Key by ID.
      #
      # @param [Contentful::Management::Client] client
      # @param [String] space_id
      # @param [String] api_key_id
      #
      # @return [Contentful::Management::ApiKey]
      def self.find(client, space_id, api_key_id)
        super(client, space_id, nil, api_key_id)
      end

      # Returns the environment links associated to this Api Key
      def environments
        properties[:environments].map { |environment| Link.new(environment, nil, client) }
      end

      # Finds the Preview API Key associated to this API Key
      #
      # @return [Contentful::Management::PreviewApiKey]
      def preview_api_key
        client.preview_api_keys(space.id).find(properties[:preview_api_key].id)
      end
    end
  end
end
