# frozen_string_literal: true

require_relative 'environment_association_methods_factory'

module Contentful
  module Management
    # Wrapper for Content Type API for usage from within Environment
    # @private
    class EnvironmentContentTypeMethodsFactory
      include Contentful::Management::EnvironmentAssociationMethodsFactory
    end
  end
end
