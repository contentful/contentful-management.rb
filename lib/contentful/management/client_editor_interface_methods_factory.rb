require_relative 'editor_interface'
require_relative 'client_association_methods_factory'

module Contentful
  module Management
    # Wrapper for EditorInterface API for usage from within Client
    # @private
    class ClientEditorInterfaceMethodsFactory
      attr_reader :client

      def initialize(client, space_id, environment_id, content_type_id)
        @client = client
        @resource_requester = ResourceRequester.new(client, associated_class)
        @space_id = space_id
        @environment_id = environment_id
        @content_type_id = content_type_id
      end

      # Gets the Default Editor Interface
      #
      # @see _ For complete option list: https://www.contentful.com/developers/docs/references/content-delivery-api/#/reference/search-parameters
      #
      # @return [Contentful::Management::EditorInterface]
      def default
        @resource_requester.all(
          space_id: @space_id,
          environment_id: @environment_id,
          content_type_id: @content_type_id,
          editor_id: 'default'
        )
      end

      private

      def associated_class
        EditorInterface
      end
    end
  end
end
