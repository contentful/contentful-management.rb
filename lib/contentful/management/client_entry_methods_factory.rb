require_relative 'client_association_methods_factory'

module Contentful
  module Management
    # Wrapper for Entry API for usage from within Client
    # @private
    class ClientEntryMethodsFactory
      include Contentful::Management::ClientAssociationMethodsFactory

      def create(content_type, attributes)
        associated_class.create(client, @space_id, @environment_id, attributes.merge(content_type: content_type))
      end

      def new(*)
        fail 'Not supported'
      end
    end
  end
end
