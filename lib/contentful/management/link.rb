require_relative 'resource'

module Contentful
  module Management
    # Resource Class for Links
    # https://www.contentful.com/developers/documentation/content-delivery-api/#links
    class Link
      include Contentful::Management::Resource
      include Contentful::Management::Resource::SystemProperties

      # Queries contentful for the Resource the Link is referring to
      # @param [String] space_id
      # @param [String] environment_id
      def resolve(space_id = nil, environment_id = nil)
        return client.spaces.find(id) if link_type == 'Space'

        method = Contentful::Management::Support.base_path_for(link_type).to_sym

        if space_id && environment_id.nil?
          return client.public_send(
            method,
            space_id
          ).find(id)
        elsif space_id && environment_id
          return client.public_send(
            method,
            space_id,
            environment_id
          ).find(id)
        end

        client.public_send(method).find(id)
      end
    end
  end
end
