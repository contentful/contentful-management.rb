require_relative 'client_association_methods_factory'

module Contentful
  module Management
    # Wrapper for Upload API for usage from within Client
    # @private
    class ClientUploadMethodsFactory
      include Contentful::Management::ClientAssociationMethodsFactory

      def new(*)
        fail 'Not supported'
      end

      def all(*)
        fail 'Not supported'
      end
    end
  end
end
