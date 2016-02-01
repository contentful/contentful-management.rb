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

      # Gets a collection of api keys.
      #
      # @param [String] space_id
      # @param [Hash] _parameters the parameters for search query
      # @option _parameters [String] :name The ApiKey name
      # @option _parameters [String] :description The ApiKey description
      #
      # @return [Contentful::Management::Array<Contentful::Management::ApiKey>]
      def self.all(space_id = nil, _parameters = {})
        request = Request.new("/#{space_id}/api_keys")
        response = request.get
        result = ResourceBuilder.new(response, { 'ApiKey' => ApiKey }, {})
        result.run
      end

      # Gets a specific api key.
      #
      # @param [String] space_id
      # @param [String] api_key_id
      #
      # @return [Contentful::Management::ApiKey]
      def self.find(space_id, api_key_id)
        request = Request.new("/#{space_id}/api_keys/#{api_key_id}")
        response = request.get
        result = ResourceBuilder.new(response, { 'ApiKey' => ApiKey }, {})
        result.run
      end

      # Creates an api key.
      #
      # @param [String] space_id
      # @param [Hash] attributes
      # @option attributes [String] :name The ApiKey name
      # @option attributes [String] :description The ApiKey description
      #
      # @return [Contentful::Management::ApiKey]
      def self.create(space_id, attributes)
        request = Request.new(
          "/#{space_id}/api_keys",
          'name' => attributes.fetch(:name),
          'description' => attributes.fetch(:description, nil)
        )
        response = request.post
        result = ResourceBuilder.new(response, { 'ApiKey' => ApiKey }, {})
        result.run
      end
    end
  end
end
