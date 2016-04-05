require_relative 'client_association_methods_factory'
require_relative 'client_association_all_published_method_factory'

module Contentful
  module Management
    # Wrapper for ContentType API for usage from within Client
    # @private
    class ClientContentTypeMethodsFactory
      include Contentful::Management::ClientAssociationMethodsFactory
      include Contentful::Management::ClientAssociationAllPublishedMethodsFactory

      def all_published(space_id, params = {})
        super(space_id, { suppress_warning: true }.merge(params))
      end
    end
  end
end
