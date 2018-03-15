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

      def find(user_id)
        super(user_id)
      end

      def me
        find('me')
      end

      def all(*)
        fail 'Not supported'
      end
    end
  end
end
