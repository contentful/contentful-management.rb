require_relative 'resource'

module Contentful
  module Management
    # Resource class for WebhookHealth.
    # @see _ https://www.contentful.com/developers/docs/references/content-management-api/#/reference/webhook-calls/webhook-health
    class WebhookHealth
      include Contentful::Management::Resource
      include Contentful::Management::Resource::SystemProperties
      include Contentful::Management::Resource::Refresher

      property :calls, :hash

      # Gets a webhook's health details by ID
      #
      # @param [Contentful::Management::Client] client
      # @param [String] space_id
      # @param [String] webhook_id
      #
      # @return [Contentful::Management::WebhookHealth]
      def self.find(client, space_id, webhook_id)
        ClientWebhookHealthMethodsFactory.new(client).find(space_id, webhook_id)
      end

      # Not supported
      def self.create(*)
        fail 'Not supported'
      end

      # Not supported
      def self.all(*)
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

        "/#{space_id}/webhooks/#{webhook_id}/health"
      end

      # Not supported
      def destroy
        fail 'Not supported'
      end

      # Not supported
      def update(*)
        fail 'Not supported'
      end

      def total
        calls['total']
      end

      def healthy
        calls['healthy']
      end
    end
  end
end
