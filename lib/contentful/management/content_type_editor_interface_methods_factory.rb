require_relative 'client_editor_interface_methods_factory'
require_relative 'editor_interface'

module Contentful
  module Management
    # Wrapper for Editor Interface API for a specific Content Type
    # @private
    class ContentTypeEditorInterfaceMethodsFactory
      attr_reader :content_type, :editor_interfaces_client

      # @private
      def initialize(content_type)
        @content_type = content_type
        @editor_interfaces_client = ClientEditorInterfaceMethodsFactory.new(content_type.client)
      end

      def default
        editor_interfaces_client.default(content_type.space.id, content_type.id)
      end

      def find(id)
        editor_interfaces_client.find(content_type.space.id, content_type.id, id)
      end

      def create(id, attributes)
        editor_interfaces_client.create(content_type.space.id, content_type.id, id, attributes)
      end
    end
  end
end
