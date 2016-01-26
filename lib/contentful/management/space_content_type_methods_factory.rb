require_relative 'space_association_methods_factory'
require_relative 'space_association_all_published_method_factory'

module Contentful
  module Management
    class SpaceContentTypeMethodsFactory
      include Contentful::Management::SpaceAssociationMethodsFactory
      include Contentful::Management::SpaceAssociationAllPublishedMethodsFactory
    end
  end
end
