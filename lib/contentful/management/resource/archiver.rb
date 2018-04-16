module Contentful
  module Management
    module Resource
      # Wrapper for Resources with /archived API
      module Archiver
        # Archives a resource.
        #
        # @return [Contentful::Management::Resource]
        def archive
          ResourceRequester.new(client, self.class).archive(
            self,
            {
              space_id: space.id,
              environment_id: environment_id,
              resource_id: id,
              suffix: '/archived'
            },
            version: sys[:version]
          )
        end

        # Unarchives a resource.
        #
        # @return [Contentful::Management::Resource]
        def unarchive
          ResourceRequester.new(client, self.class).unarchive(
            self,
            {
              space_id: space.id,
              environment_id: environment_id,
              resource_id: id,
              suffix: '/archived'
            },
            version: sys[:version]
          )
        end

        # Checks if a resource is archived.
        #
        # @return [Boolean]
        def archived?
          sys[:archivedAt] ? true : false
        end
      end
    end
  end
end
