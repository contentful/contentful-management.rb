module Contentful
  module Management
    # Wrapper for /public API for usage from within Space Wrapper Classes
    # @private
    # @deprecated This call will be soon removed from the API except for Content Types
    module SpaceAssociationAllPublishedMethodsFactory
      def all_published(params = {})
        associated_class.all_published(space.client, space.id, params)
      end
    end
  end
end
