require_relative 'space_association_methods_factory'

module Contentful
  module Management
    # Wrapper for UI Extension API for usage from within Space
    # @private
    class SpaceUIExtensionMethodsFactory
      include Contentful::Management::SpaceAssociationMethodsFactory

      def new(*)
        fail 'Not supported'
      end
    end
  end
end
