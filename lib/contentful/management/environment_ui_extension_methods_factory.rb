require_relative 'environment_association_methods_factory'

module Contentful
  module Management
    # Wrapper for UI Extensions API for usage from within Environment
    # @private
    class EnvironmentUIExtensionMethodsFactory
      include Contentful::Management::EnvironmentAssociationMethodsFactory
    end
  end
end
