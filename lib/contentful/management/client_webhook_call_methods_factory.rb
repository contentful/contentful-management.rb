require_relative 'client_association_methods_factory'

module Contentful
  module Management
    # Wrapper for Webhook Call API for usage from within Client
    # @private
    class ClientWebhookCallMethodsFactory
      include Contentful::Management::ClientAssociationMethodsFactory

      def all(space_id, webhook_id, _params = {})
        @resource_requester.find(
          space_id: space_id,
          webhook_id: webhook_id
        )
      end

      def find(space_id, webhook_id, call_id)
        @resource_requester.find(
          space_id: space_id,
          webhook_id: webhook_id,
          call_id: call_id
        )
      end

      def new(*)
        fail 'Not supported'
      end
    end
  end
end
