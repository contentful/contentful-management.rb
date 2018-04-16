require_relative 'space_association_methods_factory'

module Contentful
  module Management
    # Wrapper for Environment API for usage from within Space
    # @private
    class SpaceEnvironmentMethodsFactory
      include Contentful::Management::SpaceAssociationMethodsFactory
    end
  end
end
