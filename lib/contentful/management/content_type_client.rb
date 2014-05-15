module Contentful
  module Management
    module ContentTypeClient
      def content_type(space_id, content_type_id)
        request = Request.new(self, "/#{space_id}/content_types/#{content_type_id}")
        response = request.get
        result = ResourceBuilder.new(self, response, {}, {}, default_locale)

        result.run
      end

      def content_types(space_id)
        request = Request.new(self, "/#{space_id}/content_types")
        response = request.get
        result = ResourceBuilder.new(self, response, {}, {}, default_locale)

        result.run
      end
    end
  end
end
