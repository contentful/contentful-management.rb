module Contentful
  module Management
    # Wrapper for /public API for usage from within Client Wrapper Classes
    # @private
    module ClientAssociationAllPublishedMethodsFactory
      # Gets a collection of published resources.
      #
      # @param [String] space_id
      # @param [Hash] params
      # @see _ For complete option list: http://docs.contentfulcda.apiary.io/#reference/search-parameters
      #
      # @return [Contentful::Management::Array<Contentful::Management::Resource>]
      def all_published(space_id, params = {})
        @resource_requester.all(
          { space_id: space_id, public: true },
          params
        )
      end
    end
  end
end
