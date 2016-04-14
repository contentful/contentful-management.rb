require_relative 'resource'

module Contentful
  module Management
    # Resource class for Editor Interface.
    class EditorInterface
      include Contentful::Management::Resource
      include Contentful::Management::Resource::SystemProperties
      include Contentful::Management::Resource::Refresher

      property :controls, :array

      # Gets the Default Editor Interface
      #
      # @param [String] space_id
      # @param [String] content_type_id
      # @param [Hash] params
      # @see _ For complete option list: http://docs.contentfulcda.apiary.io/#reference/search-parameters
      #
      # @return [Contentful::Management::EditorInterface]
      def self.default(client, space_id, content_type_id)
        ClientEditorInterfaceMethodsFactory.new(client).default(space_id, content_type_id)
      end

      # Gets a specific Editor Interface.
      #
      # @param [String] space_id
      # @param [String] content_type_id
      # @param [String] id
      #
      # @return [Contentful::Management::EditorInterface]
      def self.find(client, space_id, content_type_id, id)
        ClientEditorInterfaceMethodsFactory.new(client).find(space_id, content_type_id, id)
      end

      # Creates an Editor Interface
      #
      # @param [String] space_id
      # @param [String] content_type_id
      # @param [String] id
      # @param [Hash] attributes
      # @option attributes [Array<Hash>] controls
      #
      # @return [Contentful::Management::EditorInterface]
      def self.create(client, space_id, content_type_id, id, attributes)
        ClientEditorInterfaceMethodsFactory.new(client).create(space_id, content_type_id, id, attributes)
      end

      # @private
      def self.create_attributes(_client, attributes)
        { 'controls' => attributes.fetch(:controls) }
      end

      # @private
      def self.build_endpoint(endpoint_options)
        space_id = endpoint_options.fetch(:space_id)
        content_type_id = endpoint_options.fetch(:content_type_id)
        editor_id = endpoint_options[:editor_id]

        base_endpoint = "/#{space_id}/content_types/#{content_type_id}/editor_interfaces"

        return base_endpoint if editor_id.nil?

        "#{base_endpoint}/#{editor_id}"
      end

      # Updates an Editor Interface
      #
      # @param [Hash] attributes
      # @option attributes [Array<Hash>] :controls
      #
      # @return [Contentful::Management::EditorInterface]
      def update(attributes)
        ResourceRequester.new(client, self.class).update(
          self,
          { space_id: space.id, content_type_id: content_type.id, editor_id: id },
          { 'controls' => attributes.fetch(:controls) },
          version: sys[:version]
        )
      end

      # Destroys an EditorInterface.
      #
      # Not Supported
      def destroy
        fail 'Not supported'
      end

      protected

      def refresh_find
        self.class.find(client, space.id, content_type.id, id)
      end

      def query_attributes(attributes)
        attributes.each_with_object({}) { |(k, v), result| result[k.to_sym] = v }
      end
    end
  end
end
