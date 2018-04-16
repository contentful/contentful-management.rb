module Contentful
  module Management
    module Resource
      # Mixin for environment aware resources
      module EnvironmentAware
        # Gets the environment ID for the resource.
        def environment_id
          sys.fetch(:environment, {}).fetch(:id, 'master')
        end
      end
    end
  end
end
