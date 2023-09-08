# frozen_string_literal: true

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

        # Checks if a resource has been updated since last publish.
        # Returns false if resource has not been published before.
        #
        # @return [Boolean]
        def updated?
          return false unless sys[:publishedAt]

          sanitize_date(sys[:publishedAt]) < sanitize_date(sys[:updatedAt])
        end

        private

        # In order to have a more accurate comparison due to minimal delays
        # upon publishing entries. We strip milliseconds from the dates we compare.
        #
        # @param date [::DateTime]
        # @return [::Time] without milliseconds.
        def sanitize_date(date)
          time = date.to_time

          ::Time.new(time.year, time.month, time.day, time.hour, time.min, time.sec, time.utc_offset)
        end
      end
    end
  end
end
