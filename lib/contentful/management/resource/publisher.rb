module Contentful
  module Management
    module Resource
      # Wrapper for Resources with /published API
      module Publisher
        # Publishes a resource.
        #
        # @return [Contentful::Management::Resource]
        def publish
          ResourceRequester.new(client, self.class).publish(
            self,
            {
              space_id: space.id,
              environment_id: environment_id,
              resource_id: id,
              suffix: '/published'
            },
            version: sys[:version]
          )
        end

        # Unpublishes a resource.
        #
        # @return [Contentful::Management::Resource]
        def unpublish
          ResourceRequester.new(client, self.class).unpublish(
            self,
            {
              space_id: space.id,
              environment_id: environment_id,
              resource_id: id,
              suffix: '/published'
            },
            version: sys[:version]
          )
        end

        # Checks if a resource is published.
        #
        # @return [Boolean]
        def published?
          sys[:publishedAt] ? true : false
        end
      end
    end
  end
end
