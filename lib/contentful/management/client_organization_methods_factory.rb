require_relative 'client_association_methods_factory'

module Contentful
  module Management
    # Wrapper for Organizations API for usage from within Client
    # @private
    class ClientOrganizationMethodsFactory
      include Contentful::Management::ClientAssociationMethodsFactory

      def new(*)
        fail 'Not supported'
      end

      def find(*)
        fail 'Not supported'
      end

      def all(*)
        super
      end
    end
  end
end
