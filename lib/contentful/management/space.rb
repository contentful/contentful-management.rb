require_relative 'resource'
require_relative 'space_membership'
require_relative 'space_space_membership_methods_factory'
require_relative 'locale'
require_relative 'space_locale_methods_factory'
require_relative 'content_type'
require_relative 'space_content_type_methods_factory'
require_relative 'asset'
require_relative 'space_asset_methods_factory'
require_relative 'entry'
require_relative 'space_entry_methods_factory'
require_relative 'webhook'
require_relative 'space_webhook_methods_factory'
require_relative 'role'
require_relative 'space_role_methods_factory'
require_relative 'ui_extension'
require_relative 'space_ui_extension_methods_factory'
require_relative 'editor_interface'
require_relative 'space_editor_interface_methods_factory'
require_relative 'api_key'
require_relative 'space_api_key_methods_factory'

module Contentful
  module Management
    # Resource class for Space.
    # @see _ https://www.contentful.com/developers/documentation/content-management-api/#resources-spaces
    class Space
      include Contentful::Management::Resource
      include Contentful::Management::Resource::SystemProperties
      include Contentful::Management::Resource::Refresher

      property :name, :string
      property :organization, :string
      property :locales, Locale

      attr_accessor :found_locale

      # @private
      def self.build_endpoint(endpoint_options)
        return "spaces/#{endpoint_options[:space_id]}" if endpoint_options.key?(:space_id)
        'spaces'
      end

      # Gets all Spaces
      #
      # @param [Contentful::Management::Client] client
      #
      # @return [Contentful::Management::Array<Contentful::Management::Space>]
      def self.all(client)
        ClientSpaceMethodsFactory.new(client).all
      end

      # Gets a specific space.
      #
      # @param [Contentful::Management::Client] client
      # @param [String] space_id
      #
      # @return [Contentful::Management::Space]
      def self.find(client, space_id)
        ClientSpaceMethodsFactory.new(client).find(space_id)
      end

      # @private
      def self.create_attributes(client, attributes)
        default_locale = attributes[:default_locale] || client.default_locale
        { 'name' => attributes.fetch(:name), defaultLocale: default_locale }
      end

      # @private
      def self.create_headers(_client, attributes)
        { organization_id: attributes[:organization_id] }
      end

      # @private
      def after_create(attributes)
        self.found_locale = attributes[:default_locale] || client.default_locale
      end

      # Create a space.
      #
      # @param [Contentful::Management::Client] client
      # @param [Hash] attributes
      # @option attributes [String] :name
      # @option attributes [String] :default_locale
      # @option attributes [String] :organization_id Required if user has more than one organization
      #
      # @return [Contentful::Management::Space]
      def self.create(client, attributes)
        ResourceRequester.new(client, self).create({}, attributes)
      end

      # Updates a space.
      #
      # @param [Hash] attributes
      # @option attributes [String] :name
      # @option attributes [String] :organization_id Required if user has more than one organization
      #
      # @return [Contentful::Management::Space]
      def update(attributes)
        ResourceRequester.new(client, self.class).update(
          self,
          { space_id: id },
          { 'name' => attributes.fetch(:name) },
          version: sys[:version],
          organization_id: attributes[:organization_id]
        )
      end

      # If a space is new, an object gets created in the Contentful, otherwise the existing space gets updated.
      # @see _ README for details.
      #
      # @return [Contentful::Management::Space]
      def save
        if id
          update(name: name, organization_id: organization)
        else
          new_instance = self.class.create(client, name: name, organization_id: organization)
          refresh_data(new_instance)
        end
      end

      # Destroys a space.
      #
      # @return [true, Contentful::Management::Error] success
      def destroy
        ResourceRequester.new(client, self.class).destroy(space_id: id)
      end

      # Allows manipulation of content types in context of the current space
      # Allows listing all content types of space, creating new and finding one by ID.
      # @see _ README for details.
      #
      # @return [Contentful::Management::SpaceContentTypeMethodsFactory]
      def content_types
        SpaceContentTypeMethodsFactory.new(self)
      end

      # Allows manipulation of api keys in context of the current space
      # Allows listing all api keys of space, creating new and finding one by ID.
      # @see _ README for details.
      #
      # @return [Contentful::Management::SpaceApiKeyMethodsFactory]
      def api_keys
        SpaceApiKeyMethodsFactory.new(self)
      end

      # Allows manipulation of locales in context of the current space
      # Allows listing all locales of space, creating new and finding one by ID.
      # @see _ README for details.
      #
      # @return [Contentful::Management::SpaceLocaleMethodsFactory]
      def locales
        SpaceLocaleMethodsFactory.new(self)
      end

      # Allows manipulation of space memberships in context of the current space
      # Allows listing all space memberships of space, creating new and finding one by ID.
      # @see _ README for details.
      #
      # @return [Contentful::Management::SpaceSpaceMembershipMethodsFactory]
      def space_memberships
        SpaceSpaceMembershipMethodsFactory.new(self)
      end

      # Allows manipulation of roles in context of the current space
      # Allows listing all roles of space, creating new and finding one by ID.
      # @see _ README for details.
      #
      # @return [Contentful::Management::SpaceRoleMethodsFactory]
      def roles
        SpaceRoleMethodsFactory.new(self)
      end

      # Allows manipulation of UI extension in context of the current space
      # Allows listing all UI extension of space, creating new and finding one by ID.
      # @see _ README for details.
      #
      # @return [Contentful::Management::SpaceUIExtensionMethodsFactory]
      def ui_extensions
        SpaceUIExtensionMethodsFactory.new(self)
      end

      # Allows manipulation of editor interfaces in context of the current space
      # Allows listing all editor interfaces of space, creating new and finding one by ID.
      # @see _ README for details.
      #
      # @return [Contentful::Management::SpaceEditorInterfaceMethodsFactory]
      def editor_interfaces
        SpaceEditorInterfaceMethodsFactory.new(self)
      end

      # Allows manipulation of assets in context of the current space
      # Allows listing all assets of space, creating new and finding one by ID.
      # @see _ README for details.
      #
      # @return [Contentful::Management::SpaceAssetMethodsFactory]
      def assets
        SpaceAssetMethodsFactory.new(self)
      end

      # Allows manipulation of entries in context of the current space
      # Allows listing all entries for space and finding one by ID.
      # @see _ README for details.
      #
      # @return [Contentful::Management::SpaceEntryMethodsFactory]
      def entries
        SpaceEntryMethodsFactory.new(self)
      end

      # Allows manipulation of webhooks in context of the current space
      # Allows listing all webhooks for space and finding one by ID.
      # @see _ README for details.
      #
      # @return [Contentful::Management::SpaceWebhookMethodsFactory]
      def webhooks
        SpaceWebhookMethodsFactory.new(self)
      end

      # Retrieves Default Locale for current Space and leaves it cached
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

      protected

      def refresh_find
        self.class.find(client, id)
      end
    end
  end
end
