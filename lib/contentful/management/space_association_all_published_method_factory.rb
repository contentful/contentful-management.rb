module Contentful
  module Management
    # Wrapper for /public API for usage from within Space Wrapper Classes
    # @private
    module SpaceAssociationAllPublishedMethodsFactory
      def all_published(params = {})
        associated_class.all_published(space.id, params)
      end
    end
  end
end
