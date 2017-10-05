require_relative 'client_association_methods_factory'

module Contentful
  module Management
    # Wrapper for Users API for usage from within Client
    # @private
    class ClientUserMethodsFactory
      include Contentful::Management::ClientAssociationMethodsFactory

      def new(*)
        fail 'Not supported'
      end

      def find(*)
        super(nil, nil)
      end
      alias me find

      def all(*)
        fail 'Not supported'
      end
    end
  end
end
