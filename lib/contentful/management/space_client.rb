module Contentful
  module Management
    module SpaceClient
      # Retrieves the space with space_id from the API
      # == Returns:
      # Contentful::Space Object if found, Contentful::Error otherwise
      def space(space_id)
        request = Request.new(self, "/#{space_id}")
        response = request.get
        result = ResourceBuilder.new(self, response, {}, {}, default_locale)

        result.run
      end

      # Returns the spaces a user has access too. Including all organizations the user is part of.
      # == Returns:
      # Contentful::Array a list of spaces converted to Contentful::Space Objects
      def spaces
        # TODO: add options
        request = Request.new(self, '')
        response = request.get
        result = ResourceBuilder.new(self, response, {}, {}, default_locale)

        result.run
      end

      # Deletes the space with the given ID from the api
      # == Returns:
      # true if successful, a Contentful::Error otherwise
      def delete_space(space_id)
        request = Request.new(self, "/#{space_id}")
        response = request.delete

        if response.status == :no_content
          return true
        else
          result = ResourceBuilder.new(self, response, {}, {}, default_locale)

          result.run
        end
      end

      # Creates a space with the given name, if the user is in more than one organization the organizaton id
      # needs to be specified
      # == Returns:
      # Contentful::Space Object if successful, Contentful::Error otherwise
      def create_space(name, organization = nil)
        self.organization = organization unless organization
        headers = create_space_header(name)
        request = Request.new(self, '', headers)
        response = request.post
        result = ResourceBuilder.new(self, response, {}, {}, default_locale)

        result.run
      end

      # Updates the space with the given name
      # == Returns:
      # Contentful::Space Object if successful, Contentful::Error otherwise
      def update_space(space_id, name, version)
        self.version = version
        headers = create_space_header(name)
        request = Request.new(self, "/#{space_id}", headers)
        response = request.put
        result = ResourceBuilder.new(self, response, {}, {}, default_locale)

        result.run
      end
    end
  end
end
