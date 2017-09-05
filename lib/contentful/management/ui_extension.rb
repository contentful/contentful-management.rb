require_relative 'resource'

module Contentful
  module Management
    # Resource class for UIExtension.
    # @see _ https://www.contentful.com/developers/docs/references/content-management-api/#/reference/ui-extensions
    class UIExtension
      include Contentful::Management::Resource
      include Contentful::Management::Resource::SystemProperties
      include Contentful::Management::Resource::Refresher

      property :extension, :hash

      # @private
      def self.endpoint
        'extensions'
      end

      # @private
      def self.create_attributes(_client, attributes)
        extension = attributes['extension'] || attributes[:extension]

        fail 'Invalid UI Extension attributes' unless valid_extension(extension)

        { 'extension' => extension }
      end

      # @private
      def self.valid_extension(extension)
        return false unless extension.key?('name')
        return false unless extension.key?('fieldTypes') && extension['fieldTypes'].is_a?(::Array)
        return false unless extension.key?('src') || extension.key?('srcdoc')
        return false if extension.key?('sidebar') && ![false, true].include?(extension['sidebar'])
        true
      end

      # If an extension is a new object gets created in the Contentful, otherwise the existing extension gets updated.
      # @see _ https://github.com/contentful/contentful-management.rb for details.
      #
      # @return [Contentful::Management::UIExtension]
      def save
        self.class.valid_extension(extension)
        if id
          update(extension: extension)
        else
          new_instance = self.class.create(client, sys[:space].id, extension: extension)
          refresh_data(new_instance)
        end
      end

      # Returns extension name
      # @return [String] name
      def name
        extension['name']
      end

      # Sets extension name
      # @param [String] value
      def name=(value)
        extension['name'] = value
      end

      # Returns extension field types
      # @return [Array<String>] field types
      def field_types
        extension['fieldTypes']
      end

      # Sets extension field types
      # @param [Array<String>] values
      def field_types=(values)
        extension['fieldTypes'] = values
      end

      # Returns extension source URL or data
      # @return [String] source URL or data
      def source
        extension['src'] || extension['srcdoc']
      end

      # Sets extension source
      # @param [String] value URL or data
      def source=(value)
        if value.start_with?('http')
          extension['src'] = value
          extension.delete('srcdoc')
        else
          extension['srcdoc'] = value
          extension.delete('src')
        end
      end

      # Returns if extension is on sidebar
      # @return [Boolean] sidebar
      def sidebar
        extension['sidebar']
      end

      # Sets if extension is on sidebar
      # @param [Boolean] value
      def sidebar=(value)
        extension['sidebar'] = value
      end
    end
  end
end
