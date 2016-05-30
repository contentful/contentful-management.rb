require_relative 'client_editor_interface_methods_factory'
require_relative 'editor_interface'

module Contentful
  module Management
    # Wrapper for EditorInterface API for usage from within Space
    # @private
    class SpaceEditorInterfaceMethodsFactory
      attr_reader :space, :editor_interfaces_client

      def initialize(space)
        @space = space
        @editor_interfaces_client = ClientEditorInterfaceMethodsFactory.new(space.client)
      end

      def default(content_type_id)
        editor_interfaces_client.default(space.id, content_type_id)
      end
    end
  end
end
