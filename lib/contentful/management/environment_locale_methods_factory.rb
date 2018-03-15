require_relative 'environment_association_methods_factory'

module Contentful
  module Management
    # Wrapper for Locale API for usage from within Environment
    # @private
    class EnvironmentLocaleMethodsFactory
      include Contentful::Management::EnvironmentAssociationMethodsFactory
    end
  end
end
