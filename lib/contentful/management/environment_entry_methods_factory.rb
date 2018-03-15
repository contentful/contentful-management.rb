require_relative 'environment_association_methods_factory'

module Contentful
  module Management
    # Wrapper for Entry API for usage from within Environment
    # @private
    class EnvironmentEntryMethodsFactory
      include Contentful::Management::EnvironmentAssociationMethodsFactory
    end
  end
end
