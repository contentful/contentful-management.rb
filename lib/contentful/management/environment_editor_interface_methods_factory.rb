require_relative 'environment_association_methods_factory'

module Contentful
  module Management
    # Wrapper for Editor Interface API for usage from within Environment
    # @private
    class EnvironmentEditorInterfaceMethodsFactory
      include Contentful::Management::EnvironmentAssociationMethodsFactory

      def default(content_type_id)
        associated_class.default(environment.client, environment.space.id, environment.id, content_type_id)
      end
    end
  end
end
