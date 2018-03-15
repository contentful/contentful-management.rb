require_relative 'client_association_methods_factory'

module Contentful
  module Management
    # Wrapper for Personal Access Token API for usage from within Client
    # @private
    class ClientPersonalAccessTokenMethodsFactory
      include Contentful::Management::ClientAssociationMethodsFactory

      def new(*)
        fail 'Not supported'
      end

      def all(params = {})
        super(params)
      end

      def find(personal_access_token_id)
        super(personal_access_token_id)
      end

      def create(attributes)
        super(attributes)
      end
    end
  end
end
