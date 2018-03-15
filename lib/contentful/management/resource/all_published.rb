module Contentful
  module Management
    module Resource
      # Wrapper Class for Resources with '/public' API calls
      module AllPublished
        # Gets a collection of published resources.
        #
        # @param [Contentful::Management::Client] client
        # @param [String] space_id
        # @param [Hash] parameters
        # @see _ For complete option list: https://www.contentful.com/developers/docs/references/content-delivery-api/#/reference/search-parameters
        # @option parameters [String] 'sys.id' Entry ID
        # @option parameters [String] :content_type
        # @option parameters [Integer] :limit
        # @option parameters [Integer] :skip
        # @deprecated This call will be soon removed from the API except for Content Types
        #
        # @return [Contentful::Management::Array<Contentful::Management::Resource>]
        def all_published(client, space_id, environment_id, parameters = {})
          client_association_class.new(client, space_id, environment_id).all_published(parameters)
        end
      end
    end
  end
end
