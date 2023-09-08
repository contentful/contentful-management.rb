# frozen_string_literal: true

module Contentful
  module Management
    module Resource
      # Mixin for environment aware resources
      module EnvironmentAware
        # Gets the environment ID for the resource.
        def environment_id
          env = sys.fetch(:environment, {})
          env_from_sys =
            case env
            when ::Hash
              env.fetch(:id, nil)
            when ::Contentful::Management::Link, ::Contentful::Management::Environment
              env.id
            end

          return env_from_sys if env_from_sys

          respond_to?(:content_type) && content_type && content_type.environment_id || 'master'
        end
      end
    end
  end
end
