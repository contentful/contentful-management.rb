require_relative 'resource'

module Contentful
  module Management
    # Resource class for Webhook.
    # @see _ https://www.contentful.com/developers/documentation/content-management-api/http/#resources-webhooks
    class Webhook
      include Contentful::Management::Resource
      include Contentful::Management::Resource::SystemProperties
      include Contentful::Management::Resource::Refresher

      property :url, :string
      property :httpBasicUsername, :string

      # Gets a collection of webhooks.
      #
      # @param [String] space_id
      # @param [Hash] parameters
      # @option parameters [String] 'sys.id'
      # @option parameters [String] :url
      #
      # @return [Contentful::Management::Array<Contentful::Management::Webhook>]
      def self.all(space_id, parameters = {})
        request = Request.new(
          "/#{space_id}/webhook_definitions",
          parameters
        )
        response = request.get
        result = ResourceBuilder.new(response, {}, {})
        result.run
      end

      # Gets a specific webhook.
      #
      # @param [String] space_id
      # @param [String] webhook_id
      #
      # @return [Contentful::Management::Webhook]
      def self.find(space_id, webhook_id)
        request = Request.new("/#{space_id}/webhook_definitions/#{webhook_id}")
        response = request.get
        result = ResourceBuilder.new(response, {}, {})
        result.run
      end

      # Creates a webhook.
      #
      # @param [String] space_id
      # @param [Hash] attributes
      # @option attributes [String] :url
      # @option attributes [String] :httpBasicUsername
      # @option attributes [String] :httpBasicPassword
      #
      # @return [Contentful::Management::Webhook]
      def self.create(space_id, attributes)
        id = attributes[:id]
        request = Request.new(
          "/#{space_id}/webhook_definitions/#{id}",
          endpoint_parameters(attributes)
        )
        response = id.nil? ? request.post : request.put
        ResourceBuilder.new(response, {}, {}).run
      end

      # Updates a webhook.
      #
      # @param [Hash] attributes
      # @option attributes [String] :url
      # @option attributes [String] :httpBasicUsername
      # @option attributes [String] :httpBasicPassword
      #
      # @return [Contentful::Management::Webhook]
      def update(attributes)
        request = Request.new(
          "/#{space.id}/webhook_definitions/#{id}",
          self.class.endpoint_parameters(attributes),
          nil,
          version: sys[:version]
        )
        response = request.put
        result = ResourceBuilder.new(response, {}, {})
        refresh_data(result.run)
      end

      # Destroys an webhook.
      #
      # @return [true, Contentful::Management::Error] success
      def destroy
        request = Request.new("/#{space.id}/webhook_definitions/#{id}")
        response = request.delete
        if response.status == :no_content
          true
        else
          result = ResourceBuilder.new(response, {}, {})
          result.run
        end
      end

      # @private
      def self.endpoint_parameters(attributes)
        attributes.select { |key, _value| [:httpBasicUsername, :httpBasicPassword, :url].include? key }
      end
    end
  end
end
