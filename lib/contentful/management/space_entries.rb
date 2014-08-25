module Contentful
  module Management
    class SpaceEntries

      attr_reader :space

      def initialize(space)
        @space = space
      end

      def all(params = {})
        Entry.all(space.id, params)
      end

      def find(entry_id)
        Entry.find(space.id, entry_id)
      end

    end
  end
end