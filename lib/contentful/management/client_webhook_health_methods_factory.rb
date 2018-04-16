require_relative 'client_association_methods_factory'

module Contentful
  module Management
    # Wrapper for Webhook Health API for usage from within Client
    # @private
    class ClientWebhookHealthMethodsFactory
      include Contentful::Management::ClientAssociationMethodsFactory

      # Not supported
      def all(*)
        fail 'Not supported'
      end

      def find(webhook_id)
        @resource_requester.find(
          space_id: @space_id,
          webhook_id: webhook_id
        )
      end

      def new(*)
        fail 'Not supported'
      end
    end
  end
end
