require_relative 'field'
require_relative 'support'
require_relative 'resource'
require_relative 'validation'
require_relative 'resource/publisher'
require_relative 'resource/all_published'
require_relative 'resource/environment_aware'
require_relative 'content_type_entry_methods_factory'
require_relative 'content_type_snapshot_methods_factory'
require_relative 'content_type_editor_interface_methods_factory'

module Contentful
  module Management
    # Resource class for ContentType.
    # @see _ https://www.contentful.com/developers/documentation/content-management-api/#resources-content-types
    class ContentType
      # Shortcuts for Contentful Field Types
      FIELD_TYPES = [
        SYMBOL = 'Symbol'.freeze,
        TEXT = 'Text'.freeze,
        INTEGER = 'Integer'.freeze,
        FLOAT = 'Number'.freeze,
        DATE = 'Date'.freeze,
        BOOLEAN = 'Boolean'.freeze,
        LINK = 'Link'.freeze,
        ARRAY = 'Array'.freeze,
        OBJECT = 'Object'.freeze,
        LOCATION = 'Location'.freeze,
        STRUCTURED_TEXT = 'RichText'.freeze
      ].freeze

      include Contentful::Management::Resource
      include Contentful::Management::Resource::Refresher
      include Contentful::Management::Resource::Publisher
      extend Contentful::Management::Resource::AllPublished
      include Contentful::Management::Resource::EnvironmentAware
      include Contentful::Management::Resource::SystemProperties

      property :name, :string
      property :description, :string
      property :fields, Field
      property :displayField, :string

      # @private
      def self.client_association_class
        ClientContentTypeMethodsFactory
      end

      alias activate publish
      alias deactivate unpublish
      alias active? published?

      # @private
      def self.create_attributes(_client, attributes)
        fields = fields_to_nested_properties_hash(attributes[:fields] || [])

        params = attributes.clone
        params[:fields] = fields
        params.delete(:id)
        params.delete_if { |_, v| v.nil? }
      end

      # @private
      def after_create(_attributes)
        client.register_dynamic_entry(id, DynamicEntry.create(self, client))
      end

      # @private
      def display_field_value(attributes)
        if attributes[:displayField].nil? && (display_field.nil? || display_field.empty?)
          nil
        else
          attributes[:displayField] || display_field
        end
      end

      # This method merges existing fields with new one, when adding, creating or updating new fields.
      # @private
      def merged_fields(new_field)
        field_ids = []
        merged_fields = fields.each_with_object([]) do |field, fields|
          field.deep_merge!(new_field) if field.id == new_field.id
          fields << field
          field_ids << field.id
        end
        merged_fields << new_field unless field_ids.include?(new_field.id)
        merged_fields
      end

      # @private
      alias orig_fields fields

      # Use this method only in the context of content type.
      # Allows you to add and create a field with specified attributes or destroy by pass field id.
      # @see _ README for details.
      #
      # @return [Contentful::Management::ContentType]
      def fields
        fields = orig_fields

        fields.instance_exec(self) do |content_type|
          fields.define_singleton_method(:add) do |field|
            content_type.update(fields: content_type.merged_fields(field))
          end

          fields.define_singleton_method(:create) do |params|
            field = Contentful::Management::Field.new
            Field.property_coercions.each do |key, _value|
              snakify_key = Support.snakify(key)
              param = params[snakify_key.to_sym]
              field.send("#{snakify_key}=", param) if param
            end
            content_type.update(fields: content_type.merged_fields(field))
          end

          fields.define_singleton_method(:destroy) do |id|
            fields = content_type.fields.reject { |field| field.id == id }
            content_type.update(fields: fields)
          end
        end

        fields
      end

      # Use this method only in the context of content type.
      # Allows you to create an entry.
      # @see _ README for details.
      #
      # @private
      #
      # @return [Contentful::Management::ContentTypeEntryMethodsFactory]
      def entries
        Contentful::Management::ContentTypeEntryMethodsFactory.new(self)
      end

      # Use this method only in the context of content type.
      # Allows you to create an editor interface.
      # @see _ README for details.
      #
      # @private
      #
      # @return [Contentful::Management::ContentTypeEditorInterfaceMethodsFactory]
      def editor_interface
        Contentful::Management::ContentTypeEditorInterfaceMethodsFactory.new(self)
      end

      # Allows manipulation of snapshots in context of the current content type
      # Allows listing all snapshots belonging to this entry and finding one by id.
      # @see _ README for details.
      #
      # @return [Contentful::Management::ContentTypeSnapshotMethodsFactory]
      def snapshots
        ContentTypeSnapshotMethodsFactory.new(self)
      end

      # @private
      def self.fields_to_nested_properties_hash(fields)
        fields.map do |field|
          field.properties.replace(field.properties_to_hash)
        end
      end

      protected

      def query_attributes(attributes)
        parameters = {}
        parameters[:displayField] = display_field_value(attributes)
        parameters[:name] = attributes[:name] || name
        parameters[:description] = attributes[:description] || description
        parameters[:fields] = self.class.fields_to_nested_properties_hash(attributes[:fields] || fields)

        parameters.delete_if { |_, v| v.nil? }
      end
    end
  end
end
