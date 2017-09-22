require_relative 'resource'

module Contentful
  module Management
    # Resource class for WebhookCall.
    # @see _ https://www.contentful.com/developers/docs/references/content-management-api/#/reference/webhook-calls
    class WebhookCall
      include Contentful::Management::Resource
      include Contentful::Management::Resource::SystemProperties
      include Contentful::Management::Resource::Refresher

      property :statusCode, :integer
      property :errors, :array
      property :eventType, :string
      property :url, :array
      property :requestAt, :date
      property :responseAt, :date
      property :response, :hash
      property :request, :hash

      # Gets all webhook call details for a webhook.
      #
      # @param [Contentful::Management::Client] client
      # @param [String] space_id
      # @param [String] webhook_id
      #
      # @return [Contentful::Management::Array<Contentful::Management::WebhookCall>]
      def self.all(client, space_id, webhook_id)
        ClientWebhookCallMethodsFactory.new(client).all(space_id, webhook_id)
      end

      # Gets a webhook's call details by ID
      #
      # @param [Contentful::Management::Client] client
      # @param [String] space_id
      # @param [String] webhook_id
      # @param [String] call_id
      #
      # @return [Contentful::Management::WebhookCall]
      def self.find(client, space_id, webhook_id, call_id)
        ClientWebhookCallMethodsFactory.new(client).find(space_id, webhook_id, call_id)
      end

      # Not supported
      def self.create(*)
        fail 'Not supported'
      end

      # @private
      def self.endpoint
        'webhooks'
      end

      # @private
      def self.build_endpoint(endpoint_options)
        space_id = endpoint_options.fetch(:space_id)
        webhook_id = endpoint_options.fetch(:webhook_id)
        call_id = endpoint_options.fetch(:call_id, nil)

        endpoint = "/#{space_id}/webhooks/#{webhook_id}/calls"
        endpoint = "#{endpoint}/#{call_id}" unless call_id.nil?

        endpoint
      end

      # Not supported
      def destroy
        fail 'Not supported'
      end

      # Not supported
      def update(*)
        fail 'Not supported'
      end
    end
  end
end
