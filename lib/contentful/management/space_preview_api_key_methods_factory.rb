require_relative 'space_association_methods_factory'

module Contentful
  module Management
    # Wrapper for PreviewApiKey API for usage from within Space
    # @private
    class SpacePreviewApiKeyMethodsFactory
      include Contentful::Management::SpaceAssociationMethodsFactory

      def new
        fail 'Not supported'
      end

      def create
        fail 'Not supported'
      end
    end
  end
end
