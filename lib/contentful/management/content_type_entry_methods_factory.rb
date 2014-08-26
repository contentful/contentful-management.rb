module Contentful
  module Management
    class ContentTypeEntryMethodsFactory

      attr_reader :content_type

      def initialize(content_type)
        @content_type = content_type
      end

      def all(params = {})
        Entry.all(content_type.space.id, params.merge(content_type: content_type.id))
      end

      def create(attributes)
        Entry.create(content_type, attributes)
      end

      def new
        dynamic_entry_class = content_type.client.register_dynamic_entry(content_type.id, DynamicEntry.create(content_type))
        dynamic_entry = dynamic_entry_class.new
        dynamic_entry.content_type = content_type
        dynamic_entry
      end

    end
  end
end