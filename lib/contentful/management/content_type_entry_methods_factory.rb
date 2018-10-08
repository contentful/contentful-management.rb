require_relative 'resource_requester'

module Contentful
  module Management
    # Wrapper for Entry manipulation for a specific Content Type
    # @private
    class ContentTypeEntryMethodsFactory
      attr_reader :content_type

      # @private
      def initialize(content_type)
        @content_type = content_type
      end

      # Gets all entries for a specific ContentType
      #
      # @param [Hash] params
      # @see _ For complete option list: https://www.contentful.com/developers/docs/references/content-delivery-api/#/reference/search-parameters
      # @option params [String] 'sys.id'
      # @option params [String] :limit
      # @option params [String] :skip
      # @option params [String] :order
      #
      # @return [Contentful::Management::Array<Contentful::Management::Entry>]
      def all(params = {})
        Entry.all(content_type.client, content_type.space.id, content_type.environment_id, params.merge(content_type: content_type.id))
      end

      # Creates an entry for a content type.
      #
      # @param [Hash] attributes
      #
      # @return [Contentful::Management::Entry]
      def create(attributes)
        attributes[:content_type] = content_type
        Entry.create(content_type.client, content_type.space.id, content_type.environment_id, attributes)
      end

      # Instantiates an empty entry for a content type.
      #
      # @return [Contentful::Management::Entry]
      def new
        dynamic_entry_class = content_type.client.register_dynamic_entry(
          content_type.id,
          DynamicEntry.create(content_type, content_type.client)
        )
        dynamic_entry = dynamic_entry_class.new
        dynamic_entry.space = content_type.space
        dynamic_entry.content_type = content_type
        dynamic_entry
      end
    end
  end
end
