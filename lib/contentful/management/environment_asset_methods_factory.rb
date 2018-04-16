require_relative 'environment_association_methods_factory'

module Contentful
  module Management
    # Wrapper for Asset API for usage from within Environment
    # @private
    class EnvironmentAssetMethodsFactory
      include Contentful::Management::EnvironmentAssociationMethodsFactory
    end
  end
end
