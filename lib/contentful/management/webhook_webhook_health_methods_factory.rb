require_relative 'resource_requester'

module Contentful
  module Management
    # Wrapper for webhook health information for a specific webhook.
    # @private
    class WebhookWebhookHealthMethodsFactory
      attr_reader :webhook

      # @private
      def initialize(webhook)
        @webhook = webhook
      end

      # Not supported
      def all(*)
        fail 'Not supported'
      end

      # Gets a webhook call detail for a specific webhook by ID.
      #
      # @return [Contentful::Management::WebhookCall]
      def find
        WebhookHealth.find(webhook.client, webhook.space.id, webhook.id)
      end
    end
  end
end
