require_relative 'resource'

module Contentful
  module Management
    class ApiKey
      include Contentful::Management::Resource
      include Contentful::Management::Resource::SystemProperties
      include Contentful::Management::Resource::Refresher

      property :name
      property :description
      property :accessToken
      property :policies

      # Gets a collection of api keys.
      # Takes an id of a space.
      # Returns a Contentful::Management::Array of Contentful::Management::ApiKey.
      def self.all(space_id = nil, _parameters = {})
        request = Request.new("/#{ space_id }/api_keys")
        response = request.get
        result = ResourceBuilder.new(response, {'ApiKey' => ApiKey}, {})
        result.run
      end

      # Gets a specific api key.
      # Takes an id of a space and api key id.
      # Returns a Contentful::Management::ApiKey.
      def self.find(space_id, api_key_id)
        request = Request.new("/#{ space_id }/api_keys/#{ api_key_id }")
        response = request.get
        result = ResourceBuilder.new(response, {'ApiKey' => ApiKey}, {})
        result.run
      end

      # Creates an api key.
      # Takes a space id and hash with attributes:
      #   :name
      #   :description
      # Returns a Contentful::Management::ApiKey.
      def self.create(space_id, attributes)
        request = Request.new(
            "/#{ space_id }/api_keys",
            'name' => attributes.fetch(:name),
            'description' => attributes.fetch(:description, nil)
        )
        response = request.post
        result = ResourceBuilder.new(response, {'ApiKey' => ApiKey}, {})
        result.run
      end
    end
  end
end
