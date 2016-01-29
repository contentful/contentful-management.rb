require_relative 'resource'
require_relative 'field'
require_relative 'validation'
require_relative 'content_type_entry_methods_factory'
require_relative 'support'

module Contentful
  module Management
    # Resource class for ContentType.
    # @see _ https://www.contentful.com/developers/documentation/content-management-api/#resources-content-types
    class ContentType
      # Shortcuts for Contentful Field Types
      FIELD_TYPES = [
        SYMBOL = 'Symbol',
        TEXT = 'Text',
        INTEGER = 'Integer',
        FLOAT = 'Number',
        DATE = 'Date',
        BOOLEAN = 'Boolean',
        LINK = 'Link',
        ARRAY = 'Array',
        OBJECT = 'Object',
        LOCATION = 'Location'
      ]

      include Contentful::Management::Resource
      include Contentful::Management::Resource::SystemProperties
      include Contentful::Management::Resource::Refresher

      property :name, :string
      property :description, :string
      property :fields, Field
      property :displayField, :string

      # Gets a collection of content types.
      #
      # @param [String] space_id
      # @param [Hash] query Search Options
      # @see _ For complete option list: http://docs.contentfulcda.apiary.io/#reference/search-parameters
      # @option query [String] 'sys.id' Content Type ID
      # @option query [String] :name Kind of Content Type
      # @option query [Integer] :limit
      # @option query [Integer] :skip
      #
      # @return [Contentful::Management::Array<Contentful::Management::ContentType>]
      def self.all(space_id, query = {})
        request = Request.new(
          "/#{space_id}/content_types",
          query
        )
        response = request.get
        result = ResourceBuilder.new(response, {}, {})
        content_types = result.run
        client.update_dynamic_entry_cache!(content_types)
        content_types
      end

      # Gets a collection of published content types.
      #
      # @param [String] space_id
      # @param [Hash] query Search Options
      # @see _ For complete option list: http://docs.contentfulcda.apiary.io/#reference/search-parameters
      # @option query [String] 'sys.id' Content Type ID
      # @option query [String] :name Kind of Content Type
      # @option query [Integer] :limit
      # @option query [Integer] :skip
      #
      # @return [Contentful::Management::Array<Contentful::Management::ContentType>]
      def self.all_published(space_id, query = {})
        request = Request.new(
          "/#{space_id}/public/content_types",
          query
        )
        response = request.get
        result = ResourceBuilder.new(response, {}, {})
        content_types = result.run
        client.update_dynamic_entry_cache!(content_types)
        content_types
      end

      # Gets a specific content type.
      #
      # @param [String] space_id
      # @param [String] content_type_id
      #
      # @return [Contentful::Management::ContentType]
      def self.find(space_id, content_type_id)
        request = Request.new("/#{space_id}/content_types/#{content_type_id}")
        response = request.get
        result = ResourceBuilder.new(response, {}, {})
        content_type = result.run
        client.register_dynamic_entry(content_type.id, DynamicEntry.create(content_type)) if content_type.is_a?(self)
        content_type
      end

      # Destroys a content type.
      #
      # @return [true, Contentful::Management::Error] success
      def destroy
        request = Request.new("/#{space.id}/content_types/#{id}")
        response = request.delete
        if response.status == :no_content
          return true
        else
          result = ResourceBuilder.new(response, {}, {})
          result.run
        end
      end

      # Activates a content type.
      # Returns a Contentful::Management::ContentType.
      def activate
        request = Request.new(
          "/#{space.id}/content_types/#{id}/published",
          {},
          nil,
          version: sys[:version]
        )
        response = request.put
        result = ResourceBuilder.new(response, {}, {}).run
        refresh_data(result)
      end

      # Deactivates a content type.
      # Only content type that has no entries can be deactivated.
      #
      # @return [Contentful::Management::ContentType]
      def deactivate
        request = Request.new("/#{space.id}/content_types/#{id}/published")
        response = request.delete
        result = ResourceBuilder.new(response, {}, {}).run
        refresh_data(result)
      end

      # Checks if a content type is active.
      #
      # @return [Boolean]
      def active?
        sys[:publishedAt] ? true : false
      end

      # Creates a content type.
      #
      # @param [String] space_id
      # @param [Hash] attributes
      # @option attributes [String] :id
      # @option attributes [String] :name
      # @option attributes [::Array<Contentful::Management::Field>] :fields
      #
      # @return [Contentful::Management::ContentType]
      def self.create(space_id, attributes)
        fields = fields_to_nested_properties_hash(attributes[:fields] || [])

        params = attributes.clone
        params[:fields] = fields
        params.delete(:id)
        params = params.delete_if { |_, v| v.nil? }

        request = Request.new(
          "/#{space_id}/content_types/#{attributes[:id]}",
          params
        )
        response = attributes[:id].nil? ? request.post : request.put
        result = ResourceBuilder.new(response, {}, {}).run
        client.register_dynamic_entry(result.id, DynamicEntry.create(result)) if result.is_a?(self.class)
        result
      end

      # @private
      def display_field_value(attributes)
        if attributes[:displayField].nil? && (display_field.nil? || display_field.empty?)
          nil
        else
          attributes[:displayField] || display_field
        end
      end

      # Updates a content type.
      #
      # @param [Hash] attributes
      # @option attributes [String] :id
      # @option attributes [String] :name
      # @option attributes [::Array<Contentful::Management::Field>] :fields
      #
      # @return [Contentful::Management::ContentType]
      def update(attributes)
        parameters = {}
        parameters.merge!(displayField: display_field_value(attributes))
        parameters.merge!(name: (attributes[:name] || name))
        parameters.merge!(description: (attributes[:description] || description))
        parameters.merge!(fields: self.class.fields_to_nested_properties_hash(attributes[:fields] || fields))

        parameters = parameters.delete_if { |_, v| v.nil? }
        request = Request.new(
          "/#{space.id}/content_types/#{id}",
          parameters,
          nil,
          version: sys[:version]
        )
        response = request.put
        result = ResourceBuilder.new(response, {}, {}).run
        refresh_data(result)
      end

      # If a content type is a new object gets created in the Contentful, otherwise the existing entry gets updated.
      # @see _ README for details.
      #
      # @return [Contentful::Management::ContentType]
      def save
        if id
          update(@properties)
        else
          new_instance = self.class.create(space.id, @properties)
          refresh_data(new_instance)
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
      alias_method :orig_fields, :fields

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
            fields = content_type.fields.select { |field| field.id != id }
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

      # @private
      def self.fields_to_nested_properties_hash(fields)
        fields.map do |field|
          field.properties.replace(field.properties_to_hash)
        end
      end
    end
  end
end
