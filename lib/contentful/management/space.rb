require_relative 'resource'
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

module Contentful
  module Management
    # Resource class for Space.
    # https://www.contentful.com/developers/documentation/content-management-api/#resources-spaces
    class Space
      include Contentful::Management::Resource
      include Contentful::Management::Resource::SystemProperties
      include Contentful::Management::Resource::Refresher

      property :name, :string
      property :organization, :string
      property :locales, Locale

      attr_accessor :found, :found_locale

      # Gets a collection of spaces.
      # Returns a Contentful::Management::Array of Contentful::Management::Space.
      def self.all
        request = Request.new('')
        response = request.get
        result = ResourceBuilder.new(response, {}, {})
        spaces = result.run
        spaces.each do |space|
          space.found = true
        end
        client.update_dynamic_entry_cache_for_spaces!(spaces)
        spaces
      end

      # Gets a specific space.
      # Takes an id of space.
      # Returns a Contentful::Management::Space.
      def self.find(space_id)
        request = Request.new("/#{ space_id }")
        response = request.get
        result = ResourceBuilder.new(response, {}, {})
        space = result.run
        space.found = true if space.is_a? Space
        client.update_dynamic_entry_cache_for_space!(space) if space.is_a? Space
        space
      end

      # Create a space.
      # Takes a hash of attributes with optional organization id if client has more than one organization.
      # Returns a Contentful::Management::Space.
      def self.create(attributes)
        default_locale = attributes[:default_locale] || client.default_locale
        request = Request.new(
            '',
            {'name' => attributes.fetch(:name), defaultLocale: default_locale},
            id = nil,
            organization_id: attributes[:organization_id]
        )
        response = request.post
        result = ResourceBuilder.new(response, {}, {})
        result.run
      end

      # Updates a space.
      # Takes a hash of attributes with optional organization id if client has more than one organization.
      # Returns a Contentful::Management::Space.
      def update(attributes)
        request = Request.new(
            "/#{ id }",
            {'name' => attributes.fetch(:name)},
            id = nil,
            version: sys[:version],
            organization_id: attributes[:organization_id]
        )
        response = request.put
        result = ResourceBuilder.new(response, {}, {})
        refresh_data(result.run)
      end

      # If a space is new, an object gets created in the Contentful, otherwise the existing space gets updated.
      # See README for details.
      def save
        if id
          update(name: name, organization_id: organization)
        else
          new_instance = self.class.create(name: name, organization_id: organization)
          refresh_data(new_instance)
        end
      end

      # Destroys a space.
      # Returns true if succeed.
      def destroy
        request = Request.new("/#{ id }")
        response = request.delete
        if response.status == :no_content
          return true
        else
          ResourceBuilder.new(response, {}, {}).run
        end
      end

      # Allows manipulation of content types in context of the current space
      # Allows listing all content types of space, creating new and finding one by id.
      # See README for details.
      def content_types
        SpaceContentTypeMethodsFactory.new(self)
      end

      # Allows manipulation of locales in context of the current space
      # Allows listing all locales of space, creating new and finding one by id.
      # See README for details.
      def locales
        SpaceLocaleMethodsFactory.new(self)
      end

      # Allows manipulation of assets in context of the current space
      # Allows listing all assets of space, creating new and finding one by id.
      # See README for details.
      def assets
        SpaceAssetMethodsFactory.new(self)
      end

      # Allows manipulation of entries in context of the current space
      # Allows listing all entries for space and finding one by id.
      # See README for details.
      def entries
        SpaceEntryMethodsFactory.new(self)
      end

      # Allows manipulation of webhooks in context of the current space
      # Allows listing all webhooks for space and finding one by id.
      # See README for details.
      def webhooks
        SpaceWebhookMethodsFactory.new(self)
      end

      # Retrieves Default Locale for current Space and leaves it cached
      def default_locale
        self.found_locale ||= self.found ? find_locale : @default_locale
      end

      # Finds Default Locale Code for current Space
      # This request makes an API call to the Locale endpoint
      def find_locale
        locale = ::Contentful::Management::Locale.all(self.id).detect { |l| l.default }
        return locale.code unless locale.nil?
        @default_locale
      end
    end
  end
end
