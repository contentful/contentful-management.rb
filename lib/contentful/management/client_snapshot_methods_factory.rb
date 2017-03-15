require_relative 'client_association_methods_factory'

module Contentful
  module Management
    # Wrapper for Webhook API for usage from within Client
    # @private
    class ClientSnapshotMethodsFactory
      include Contentful::Management::ClientAssociationMethodsFactory

      def create(*)
        fail 'Not supported'
      end

      def all(space_id, entry_id, _params = {})
        @resource_requester.find(
          space_id: space_id,
          entry_id: entry_id
        )
      end

      def find(space_id, entry_id, snapshot_id)
        @resource_requester.find(
          space_id: space_id,
          entry_id: entry_id,
          snapshot_id: snapshot_id
        )
      end

      def new(*)
        fail 'Not supported'
      end
    end
  end
end
