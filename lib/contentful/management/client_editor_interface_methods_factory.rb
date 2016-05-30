require_relative 'client_association_methods_factory'
require_relative 'editor_interface'

module Contentful
  module Management
    # Wrapper for EditorInterface API for usage from within Client
    # @private
    class ClientEditorInterfaceMethodsFactory
      attr_reader :client

      def initialize(client)
        @client = client
        @resource_requester = ResourceRequester.new(client, associated_class)
      end

      # Gets the Default Editor Interface
      #
      # @param [String] space_id
      # @param [String] content_type_id
      # @param [Hash] params
      # @see _ For complete option list: http://docs.contentfulcda.apiary.io/#reference/search-parameters
      #
      # @return [Contentful::Management::EditorInterface]
      def default(space_id, content_type_id)
        @resource_requester.all(space_id: space_id, content_type_id: content_type_id, editor_id: 'default')
      end

      private

      def associated_class
        EditorInterface
      end
    end
  end
end
