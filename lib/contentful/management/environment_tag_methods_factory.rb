require_relative 'environment_association_methods_factory'

module Contentful
  module Management
    # Wrapper for Tag API for usage from within Environment
    # @private
    class EnvironmentTagMethodsFactory
      include Contentful::Management::EnvironmentAssociationMethodsFactory
    end
  end
end
