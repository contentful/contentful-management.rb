require_relative 'resource'
require_relative 'resource/environment_aware'

module Contentful
  module Management
    # Resource class for Editor Interface.
    class EditorInterface
      include Contentful::Management::Resource
      include Contentful::Management::Resource::Refresher
      include Contentful::Management::Resource::SystemProperties
      include Contentful::Management::Resource::EnvironmentAware

      property :controls, :array

      # Gets the Default Editor Interface
      #
      # @param [Contentful::Management::Client] client
      # @param [String] space_id
      # @param [String] content_type_id
      #
      # @return [Contentful::Management::EditorInterface]
      def self.default(client, space_id, environment_id, content_type_id)
        ClientEditorInterfaceMethodsFactory.new(client, space_id, environment_id, content_type_id).default
      end

      # Finds an EditorInterface.
      #
      # Not Supported
      def self.find(*)
        fail 'Not supported'
      end

      # Creates an EditorInterface.
      #
      # Not Supported
      def self.create(*)
        fail 'Not supported'
      end

      # @private
      def self.create_attributes(_client, attributes)
        { 'controls' => attributes.fetch(:controls) }
      end

      # @private
      def self.build_endpoint(endpoint_options)
        space_id = endpoint_options.fetch(:space_id)
        environment_id = endpoint_options.fetch(:environment_id)
        content_type_id = endpoint_options.fetch(:content_type_id)

        "spaces/#{space_id}/environments/#{environment_id}/content_types/#{content_type_id}/editor_interface"
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
          {
            space_id: space.id,
            environment_id: environment_id,
            content_type_id: content_type.id,
            editor_id: id
          },
          { 'controls' => attributes[:controls] || controls },
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
        self.class.default(client, space.id, environment_id, content_type.id)
      end

      def query_attributes(attributes)
        attributes.each_with_object({}) { |(k, v), result| result[k.to_sym] = v }
      end
    end
  end
end
