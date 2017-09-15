require_relative 'resource'
require_relative 'webhook_webhook_call_methods_factory'

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
      property :name, :string
      property :headers, :array
      property :topics, :array

      # @private
      def self.endpoint
        'webhook_definitions'
      end

      # @private
      def self.create_attributes(_client, attributes)
        attributes.select { |key, _value| [:httpBasicUsername, :httpBasicPassword, :url, :name, :headers, :topics].include? key }
      end

      # Allows manipulation of webhook call details in context of the current webhook
      # Allows listing all webhook call details for the webhook and finding one by ID.
      # @see _ README for details.
      #
      # @return [Contentful::Management::WebhookWebhookCallMethodsFactory]
      def webhook_calls
        WebhookWebhookCallMethodsFactory.new(self)
      end

      protected

      def query_attributes(attributes)
        self.class.create_attributes(nil, attributes)
      end
    end
  end
end
