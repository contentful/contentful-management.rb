module Contentful
  module Management
    module Resource
      # Mixin for environment aware resources
      module EnvironmentAware
        # Gets the environment ID for the resource.
        def environment_id
          env = sys.fetch(:environment, {})
          case env
          when ::Hash
            env.fetch(:id, 'master')
          when ::Contentful::Management::Link
            env.id
          else
            'master'
          end
        end
      end
    end
  end
end
