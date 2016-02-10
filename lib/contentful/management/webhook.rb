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

      # @private
      def self.endpoint
        'webhook_definitions'
      end

      # @private
      def self.create_attributes(_client, attributes)
        attributes.select { |key, _value| [:httpBasicUsername, :httpBasicPassword, :url].include? key }
      end

      protected

      def query_attributes(attributes)
        self.class.create_attributes(nil, attributes)
      end
    end
  end
end
