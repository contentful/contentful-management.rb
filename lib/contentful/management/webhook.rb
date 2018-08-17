require_relative 'resource'
require_relative 'webhook_webhook_call_methods_factory'
require_relative 'webhook_webhook_health_methods_factory'

module Contentful
  module Management
    # Resource class for Webhook.
    # @see _ https://www.contentful.com/developers/documentation/content-management-api/http/#resources-webhooks
    class Webhook
      include Contentful::Management::Resource
      include Contentful::Management::Resource::Refresher
      include Contentful::Management::Resource::SystemProperties

      property :url, :string
      property :name, :string
      property :topics, :array
      property :headers, :array
      property :httpBasicUsername, :string
      property :filters, :array
      property :transformation, :hash

      # @private
      def self.endpoint
        'webhook_definitions'
      end

      # @private
      def self.create_attributes(_client, attributes)
        keys = %i[httpBasicUsername httpBasicPassword url name headers topics filters transformation]
        attributes.select { |key, _value| keys.include? key }
      end

      # Creates a webhook.
      #
      # @param [Contentful::Management::Client] client
      # @param [String] space_id
      # @param [Hash] attributes
      # @see _ README for full attribute list for each resource.
      #
      # @return [Contentful::Management::Webhook]
      def self.create(client, space_id, attributes = {})
        super(client, space_id, nil, attributes)
      end

      # Finds a webhook by ID.
      #
      # @param [Contentful::Management::Client] client
      # @param [String] space_id
      # @param [String] webhook_id
      #
      # @return [Contentful::Management::Webhook]
      def self.find(client, space_id, webhook_id)
        super(client, space_id, nil, webhook_id)
      end

      # Allows manipulation of webhook call details in context of the current webhook
      # Allows listing all webhook call details for the webhook and finding one by ID.
      # @see _ README for details.
      #
      # @return [Contentful::Management::WebhookWebhookCallMethodsFactory]
      def webhook_calls
        WebhookWebhookCallMethodsFactory.new(self)
      end

      # Allows manipulation of webhook health details in context of the current webhook
      # Allows listing webhook health details for the webhook.
      # @see _ README for details.
      #
      # @return [Contentful::Management::WebhookWebhookHealthMethodsFactory]
      def webhook_health
        WebhookWebhookHealthMethodsFactory.new(self)
      end

      protected

      def query_attributes(attributes)
        self.class.create_attributes(nil, attributes)
      end
    end
  end
end
