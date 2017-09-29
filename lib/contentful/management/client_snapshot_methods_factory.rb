require_relative 'client_association_methods_factory'

module Contentful
  module Management
    # Wrapper for Webhook API for usage from within Client
    # @private
    class ClientSnapshotMethodsFactory
      include Contentful::Management::ClientAssociationMethodsFactory

      def initialize(client, resource_type)
        super(client)
        @resource_type = resource_type
      end

      def create(*)
        fail 'Not supported'
      end

      def all(space_id, resource_id, params = {})
        @resource_requester.all(
          {
            resource_type: @resource_type,
            space_id: space_id,
            resource_id: resource_id
          },
          params
        )
      end

      def find(space_id, resource_id, snapshot_id)
        @resource_requester.find(
          resource_type: @resource_type,
          space_id: space_id,
          resource_id: resource_id,
          snapshot_id: snapshot_id
        )
      end

      def new(*)
        fail 'Not supported'
      end
    end
  end
end
