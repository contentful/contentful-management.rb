require_relative 'client_association_methods_factory'

module Contentful
  module Management
    # Wrapper for Role API for usage from within Client
    # @private
    class ClientRoleMethodsFactory
      include Contentful::Management::ClientAssociationMethodsFactory

      def new(*)
        fail 'Not supported'
      end

      def find(resource_id)
        associated_class.find(client, @space_id, resource_id)
      end

      def create(attributes)
        associated_class.create(client, @space_id, attributes)
      end
    end
  end
end
