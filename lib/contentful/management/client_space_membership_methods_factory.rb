require_relative 'client_association_methods_factory'

module Contentful
  module Management
    # Wrapper for Space Membership API for usage from within Client
    # @private
    class ClientSpaceMembershipMethodsFactory
      include Contentful::Management::ClientAssociationMethodsFactory

      def new(*)
        fail 'Not supported'
      end
    end
  end
end
