module Contentful
  module Management
    module SpaceClient
      def space(space_id)
        request = Request.new(self, "/#{space_id}")
        response = request.get
        result = ResourceBuilder.new(self, response, {}, {}, default_locale)

        result.run
      end

      def spaces
        # TODO: add options
        request = Request.new(self, '')
        response = request.get
        result = ResourceBuilder.new(self, response, {}, {}, default_locale)

        result.run
      end

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

      def create_space(name, organization = nil)
        self.organization = organization unless organization
        headers = create_space_header(name)
        request = Request.new(self, '', headers)
        response = request.post
        result = ResourceBuilder.new(self, response, {}, {}, default_locale)

        result.run
      end
    end
  end
end
