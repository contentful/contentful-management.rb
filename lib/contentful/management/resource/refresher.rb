module Contentful
  module Management
    module Resource
      # Adds the feature to have properties and system data reload for Resource.
      module Refresher
        # Reload an object
        # Updates the current version of the object to the version on the system
        def reload
          self_class = self.class
          resource = self.is_a?(Space) ? self_class.find(id) : self_class.find(space.id, id)
          refresh_data(resource) if resource.is_a? self_class
        end

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
