module Contentful
  module Resource
    # Adds the feature to have properties and system data reload for Resource.
    module Refresher

      def refresh_data(resource)
        @properties = resource.properties
        @sys = resource.sys
        self
      end
    end
  end
end
