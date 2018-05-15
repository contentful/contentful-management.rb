require_relative 'resource'

module Contentful
  module Management
    # Resource class for PreviewApiKey.
    # @see _ https://www.contentful.com/developers/docs/references/content-management-api/#/reference/api-keys/preview-api-key/get-a-single-preview-api-key
    class PreviewApiKey
      include Contentful::Management::Resource
      include Contentful::Management::Resource::Refresher
      include Contentful::Management::Resource::SystemProperties

      property :name
      property :description
      property :accessToken
      property :environments

      # Finds a Preview API Key by ID.
      #
      # @param [Contentful::Management::Client] client
      # @param [String] space_id
      # @param [String] preview_api_key_id
      #
      # @return [Contentful::Management::PreviewApiKey]
      def self.find(client, space_id, preview_api_key_id)
        super(client, space_id, nil, preview_api_key_id)
      end
    end
  end
end
