require_relative 'environment_asset_methods_factory'
require_relative 'environment_entry_methods_factory'
require_relative 'environment_locale_methods_factory'
require_relative 'environment_content_type_methods_factory'
require_relative 'environment_ui_extension_methods_factory'
require_relative 'environment_editor_interface_methods_factory'

module Contentful
  module Management
    # Resource class for Environment.
    # @see _ https://www.contentful.com/developers/documentation/content-management-api/#resources-environments
    class Environment
      include Contentful::Management::Resource
      include Contentful::Management::Resource::Refresher
      include Contentful::Management::Resource::SystemProperties

      property :name, :string

      # @private
      def self.build_endpoint(endpoint_options)
        space_id = endpoint_options.fetch(:space_id)
        environment_id = endpoint_options.fetch(:resource_id, endpoint_options.fetch(:environment_id, nil))

        endpoint = "spaces/#{space_id}/environments"
        endpoint = "#{endpoint}/#{environment_id}" if environment_id
        endpoint
      end

      # Creates an environment.
      #
      # @param [Contentful::Management::Client] client
      # @param [String] space_id
      # @param [Hash] attributes
      # @see _ README for full attribute list for each resource.
      #
      # @return [Contentful::Management::Environment]
      def self.create(client, space_id, attributes = {})
        super(client, space_id, nil, attributes)
      end

      # Finds an environment by ID.
      #
      # @param [Contentful::Management::Client] client
      # @param [String] space_id
      # @param [String] environment_id
      #
      # @return [Contentful::Management::Environment]
      def self.find(client, space_id, environment_id)
        super(client, space_id, nil, environment_id)
      end

      # @private
      def self.create_attributes(_client, attributes)
        return {} if attributes.nil? || attributes.empty?

        {
          'name' => attributes.fetch(:name, attributes.fetch('name', nil))
        }
      end

      # Allows manipulation of entries in context of the current environment
      # Allows listing all entries for the current environment, creating new and finding one by ID.
      # @see _ README for details.
      #
      # @return [Contentful::Management::EnvironmentEntryMethodsFactory]
      def entries
        EnvironmentEntryMethodsFactory.new(self)
      end

      # Allows manipulation of assets in context of the current environment
      # Allows listing all assets for the current environment, creating new and finding one by ID.
      # @see _ README for details.
      #
      # @return [Contentful::Management::EnvironmentAssetMethodsFactory]
      def assets
        EnvironmentAssetMethodsFactory.new(self)
      end

      # Allows manipulation of content types in context of the current environment
      # Allows listing all content types for the current environment, creating new and finding one by ID.
      # @see _ README for details.
      #
      # @return [Contentful::Management::EnvironmentContentTypeMethodsFactory]
      def content_types
        EnvironmentContentTypeMethodsFactory.new(self)
      end

      # Allows manipulation of locales in context of the current environment
      # Allows listing all locales for the current environment, creating new and finding one by ID.
      # @see _ README for details.
      #
      # @return [Contentful::Management::EnvironmentLocaleMethodsFactory]
      def locales
        EnvironmentLocaleMethodsFactory.new(self)
      end

      # Allows manipulation of UI extensions in context of the current environment
      # Allows listing all UI extensions for the current environment, creating new and finding one by ID.
      # @see _ README for details.
      #
      # @return [Contentful::Management::EnvironmentUIExtensionMethodsFactory]
      def ui_extensions
        EnvironmentUIExtensionMethodsFactory.new(self)
      end

      # Allows manipulation of editor interfaces in context of the current environment
      # Allows listing of editor interfaces for the current environment.
      # @see _ README for details.
      #
      # @return [Contentful::Management::EnvironmentEditorInterfaceMethodsFactory]
      def editor_interfaces
        EnvironmentEditorInterfaceMethodsFactory.new(self)
      end

      # Gets the environment ID
      def environment_id
        id
      end

      # Retrieves Default Locale for current Environment and leaves it cached
      #
      # @return [String]
      def default_locale
        self.found_locale ||= find_locale
      end

      # Finds Default Locale Code for current Space
      # This request makes an API call to the Locale endpoint
      #
      # @return [String]
      def find_locale
        locale = locales.all.detect(&:default)
        return locale.code unless locale.nil?
        @default_locale
      end

      # @private
      def refresh_find
        self.class.find(client, space.id, id)
      end
    end
  end
end
