module Contentful
  module Management
    # Wrapper for /public API for usage from within Client Wrapper Classes
    # @private
    module ClientAssociationAllPublishedMethodsFactory
      # Gets a collection of published resources.
      #
      # @param [String] space_id
      # @param [Hash] params
      # @see _ For complete option list: https://www.contentful.com/developers/docs/references/content-delivery-api/#/reference/search-parameters
      # @deprecated This call will be soon removed from the API except for Content Types
      #
      # @return [Contentful::Management::Array<Contentful::Management::Resource>]
      def all_published(space_id, params = {})
        warn('This call will soon be removed from the API except for Content Types') unless params.key?(:suppress_warning)
        params.delete(:suppress_warning) if params.key?(:suppress_warning)

        @resource_requester.all(
          { space_id: space_id, public: true },
          params
        )
      end
    end
  end
end
