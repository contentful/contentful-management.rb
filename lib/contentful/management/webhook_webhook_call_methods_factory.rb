require_relative 'resource_requester'

module Contentful
  module Management
    # Wrapper for webhook call detail manipulation for a specific webhook.
    # @private
    class WebhookWebhookCallMethodsFactory
      attr_reader :webhook

      # @private
      def initialize(webhook)
        @webhook = webhook
      end

      # Gets all webhook call details for a specific webhook.
      #
      # @return [Contentful::Management::Array<Contentful::Management::WebhookCall>]
      def all(_params = {})
        WebhookCall.all(webhook.client, webhook.space.id, webhook.id)
      end

      # Gets a webhook call detail for a specific webhook by ID.
      #
      # @return [Contentful::Management::WebhookCall]
      def find(call_id)
        WebhookCall.find(webhook.client, webhook.space.id, webhook.id, call_id)
      end
    end
  end
end
