module Contentful
  module Management
    class SpaceLocales

      attr_reader :space

      def initialize(space)
        @space = space
      end

      def all
        Locale.all(space.id)
      end

      def find(locale_id)
        Locale.find(space.id, locale_id)
      end

      def create(attributes)
        Locale.create(space.id, attributes)
      end

    end
  end
end