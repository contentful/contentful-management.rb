require_relative 'resource'

module Contentful
  module Management
    # Resource Class for Links
    # https://www.contentful.com/developers/documentation/content-delivery-api/#links
    class Link
      include Contentful::Management::Resource
      include Contentful::Management::Resource::SystemProperties

      # Queries contentful for the Resource the Link is referring to
      # @param [Hash] query
      def resolve(query = {})
        id_and_query = [(id unless link_type == 'Space')].compact + [query]
        client.public_send(
          Contentful::Management::Support.snakify(link_type).to_sym,
          *id_and_query
        )
      end
    end
  end
end
