module Contentful
  module Management
    class SpaceContentTypes

      attr_reader :space

      def initialize(space)
        @space = space
      end

      def all(params = {})
        ContentType.all(space.id, params)
      end

      def find(content_type_id)
        ContentType.find(space.id, content_type_id)
      end

      def create(attributes)
        ContentType.create(space.id, attributes)
      end

      def new
        ct = ContentType.new
        ct.sys[:space] = space
        ct
      end

    end
  end
end