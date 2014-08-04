# -*- encoding: utf-8 -*-
require_relative 'resource'
require_relative 'field'

module Contentful
  module Management
    class ContentType

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

      def self.all(space_id)
        request = Request.new("/#{ space_id }/content_types")
        response = request.get
        result = ResourceBuilder.new(self, response, {}, {})
        content_types = result.run
        Contentful::Management::Client.shared_instance.update_dynamic_entry_cache!(content_types)
        content_types
      end

      def self.find(space_id, content_type_id)
        request = Request.new("/#{ space_id }/content_types/#{ content_type_id }")
        response = request.get
        result = ResourceBuilder.new(self, response, {}, {})
        content_type = result.run
        Contentful::Management::Client.shared_instance.register_dynamic_entry(content_type.id, DynamicEntry.create(content_type)) if content_type.is_a?(self)
        content_type
      end

      def destroy
        request = Request.new("/#{ space.id }/content_types/#{ id }")
        response = request.delete
        if response.status == :no_content
          return true
        else
          result = ResourceBuilder.new(self, response, {}, {})
          result.run
        end
      end

      def activate
        request = Request.new("/#{ space.id }/content_types/#{ id }/published", {}, id = nil, version: sys[:version])
        response = request.put
        result = ResourceBuilder.new(self, response, {}, {}).run
        refresh_data(result)
      end

      def deactivate
        request = Request.new("/#{ space.id }/content_types/#{ id }/published")
        response = request.delete
        result = ResourceBuilder.new(self, response, {}, {}).run
        refresh_data(result)
      end

      def active?
        !sys[:publishedAt].nil?
      end

      def self.create(space_id, attributes)
        fields = fields_to_nested_properties_hash(attributes[:fields] || [])
        request = Request.new("/#{ space_id }/content_types/#{ attributes[:id] || ''}", { name: attributes.fetch(:name),
                                                                                      description: attributes[:description],
                                                                                      fields: fields })
        response = attributes[:id].nil? ? request.post : request.put
        result = ResourceBuilder.new(self, response, {}, {}).run
        Contentful::Management::Client.shared_instance.register_dynamic_entry(result.id, DynamicEntry.create(result)) if result.is_a?(self.class)
        result
      end

      def update(attributes)
        parameters = {}
        parameters.merge!(name: (attributes[:name] || name))
        parameters.merge!(description: (attributes[:description] || description))
        parameters.merge!(fields: self.class.fields_to_nested_properties_hash(attributes[:fields] || fields))
        request = Request.new("/#{ space.id }/content_types/#{ id }", parameters, id = nil, version: sys[:version])
        response = request.put
        result = ResourceBuilder.new(self, response, {}, {}).run
        refresh_data(result)
      end

      def save
        if id.nil?
          new_instance = self.class.create(space.id, @properties)
          refresh_data(new_instance)
        else
          update(@properties)
        end
      end

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

      alias_method :orig_fields, :fields

      def fields
        fields = orig_fields

        fields.instance_exec(self) do |content_type|

          fields.define_singleton_method(:add) do |field|
            content_type.update(fields: content_type.merged_fields(field))
          end

          fields.define_singleton_method(:create) do |params|
            field = Contentful::Management::Field.new
            field.id = params.fetch(:id)
            field.name = params[:name] if params[:name]
            field.type = params[:type] if params[:type]
            field.link_type = params[:link_type] if params[:link_type]
            field.required = params[:required] if params[:required]
            field.localized = params[:localized] if params[:localized]
            field.items = params[:items] if params[:items]
            content_type.update(fields: content_type.merged_fields(field))
          end

          fields.define_singleton_method(:destroy) do |id|
            fields = content_type.fields.select { |field| field.id != id }
            content_type.update(fields: fields)
          end

        end

        fields
      end

      #TODO refactor and move
      def entries
        entries = []
        entries.instance_exec(self) do |content_type|
          define_singleton_method(:create) do |params|
            Entry.create(content_type, params)
          end
          define_singleton_method(:new) do
            dynamic_entry_class =   Contentful::Management::Client.shared_instance.register_dynamic_entry(content_type.id, DynamicEntry.create(content_type))
            dynamic_entry = dynamic_entry_class.new
            dynamic_entry.content_type = content_type
            dynamic_entry
          end
        end
        entries
      end

      private

      def self.fields_to_nested_properties_hash(fields)
        fields.map do |field|
          field.properties.replace(field.properties_to_hash)
        end
      end

    end
  end
end