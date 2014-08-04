# -*- encoding: utf-8 -*-
module Contentful
  module Management
    module Resource
      # Adds the feature to have properties and system data reload for Resource.
      module Refresher

        def refresh_data(resource)
          if resource.is_a? Error
            resource
          else
            @properties = resource.instance_variable_get(:@properties)
            @fields = resource.instance_variable_get(:@fields) if self.is_a?(Contentful::Management::Entry)
            @sys = resource.instance_variable_get(:@sys)
            self
          end
        end
      end
    end
  end
end
