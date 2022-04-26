require_relative 'client_association_methods_factory'

module Contentful
  module Management
    # Wrapper for Tag API for usage from within Client
    # @private
    class ClientTagMethodsFactory
      include Contentful::Management::ClientAssociationMethodsFactory
    end
  end
end
