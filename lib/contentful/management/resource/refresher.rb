module Contentful
  module Management
    module Resource
      # Adds the feature to have properties and system data reload for Resource.
      module Refresher
        # Reload an object
        # Updates the current version of the object to the version on the system
        def reload
          resource = refresh_find
          refresh_data(resource) if resource.is_a? self.class
        end

        # @private
        def refresh_find
          self.class.find(client, space.id, environment_id, id)
        end

        # @private
        def refresh_data(resource)
          if resource.is_a? Error
            resource
          else
            @properties = resource.instance_variable_get(:@properties)
            @fields = resource.instance_variable_get(:@fields)
            @sys = resource.instance_variable_get(:@sys).merge(locale: locale)
            self
          end
        end
      end
    end
  end
end
