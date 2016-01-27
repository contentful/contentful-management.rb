module Contentful
  module Management
    module SpaceAssociationAllPublishedMethodsFactory
      def all_published(params = {})
        associated_class.all_published(space.id, params)
      end
    end
  end
end
