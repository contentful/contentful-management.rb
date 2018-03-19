require_relative 'client_association_methods_factory'

module Contentful
  module Management
    # Wrapper for Asset API for usage from within Client
    # @private
    class ClientAssetMethodsFactory
      include Contentful::Management::ClientAssociationMethodsFactory
    end
  end
end
