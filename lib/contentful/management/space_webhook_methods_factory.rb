require_relative 'space_association_methods_factory'

module Contentful
  module Management
    class SpaceWebhookMethodsFactory
      include Contentful::Management::SpaceAssociationMethodsFactory

      def create(_attributes)
        fail 'Not supported'
      end

      def new
        fail 'Not supported'
      end
    end
  end
end
