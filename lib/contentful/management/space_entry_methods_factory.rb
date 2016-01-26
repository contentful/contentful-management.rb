require_relative 'space_association_methods_factory'
require_relative 'space_association_all_published_method_factory'

module Contentful
  module Management
    class SpaceEntryMethodsFactory
      include Contentful::Management::SpaceAssociationMethodsFactory
      include Contentful::Management::SpaceAssociationAllPublishedMethodsFactory

      def create(_attributes)
        fail 'Not supported'
      end

      def new
        fail 'Not supported'
      end
    end
  end
end
