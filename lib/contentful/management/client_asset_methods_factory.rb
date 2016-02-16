require_relative 'client_association_methods_factory'
require_relative 'client_association_all_published_method_factory'

module Contentful
  module Management
    # Wrapper for Asset API for usage from within Client
    # @private
    class ClientAssetMethodsFactory
      include Contentful::Management::ClientAssociationMethodsFactory
      include Contentful::Management::ClientAssociationAllPublishedMethodsFactory
    end
  end
end
