require_relative 'space_association_methods_factory'

module Contentful
  module Management
    # Wrapper for Role API for usage from within Space
    # @private
    class SpaceRoleMethodsFactory
      include Contentful::Management::SpaceAssociationMethodsFactory

      def new
        fail 'Not supported'
      end
    end
  end
end
