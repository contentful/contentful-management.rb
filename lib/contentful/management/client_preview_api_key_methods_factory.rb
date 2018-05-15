require_relative 'client_association_methods_factory'

module Contentful
  module Management
    # Wrapper for PreviewApiKey API for usage from within Client
    # @private
    class ClientPreviewApiKeyMethodsFactory
      include Contentful::Management::ClientAssociationMethodsFactory

      def new(*)
        fail 'Not supported'
      end

      def find(resource_id)
        associated_class.find(client, @space_id, resource_id)
      end

      def create(*)
        fail 'Not supported'
      end
    end
  end
end
