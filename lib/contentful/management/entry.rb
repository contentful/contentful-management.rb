require_relative 'resource'
require_relative 'resource_requester'
require_relative 'client_entry_methods_factory'
require_relative 'resource/entry_fields'
require_relative 'resource/fields'
require_relative 'resource/field_aware'
require_relative 'resource/all_published'
require_relative 'resource/archiver'
require_relative 'resource/publisher'

module Contentful
  module Management
    # Resource class for Entry.
    # @see _ https://www.contentful.com/developers/documentation/content-management-api/#resources-entries
    class Entry
      include Contentful::Management::Resource
      include Contentful::Management::Resource::SystemProperties
      include Contentful::Management::Resource::Refresher
      extend Contentful::Management::Resource::EntryFields
      extend Contentful::Management::Resource::AllPublished
      include Contentful::Management::Resource::Fields
      include Contentful::Management::Resource::Archiver
      include Contentful::Management::Resource::Publisher

      attr_accessor :content_type

      # @private
      def self.endpoint
        'entries'
      end

      # @private
      def self.client_association_class
        ClientEntryMethodsFactory
      end

      # @private
      def self.create_attributes(client, attributes)
        content_type = attributes[:content_type]
        fields_for_create = if attributes[:fields] # create from initialized dynamic entry via save
                              tmp_entry = new
                              tmp_entry.instance_variable_set(:@fields, attributes.delete(:fields) || {})
                              Contentful::Management::Support.deep_hash_merge(
                                tmp_entry.fields_for_query,
                                tmp_entry.fields_from_attributes(attributes)
                              )
                            else
                              fields_with_locale content_type, attributes.clone
                            end

        client.register_dynamic_entry(content_type.id, DynamicEntry.create(content_type, client))

        { fields: fields_for_create }
      end

      # @private
      def self.create_headers(_client, attributes)
        content_type = attributes[:content_type]
        content_type_id = begin
                            content_type.id
                          rescue
                            content_type[:id]
                          end

        { content_type_id: content_type_id }
      end

      # @private
      def after_create(attributes)
        self.locale = attributes[:locale] || client.default_locale
      end

      # Gets Hash of fields for the current locale
      #
      # @param [String] wanted_locale
      #
      # @return [Hash] localized fields
      def fields(wanted_locale = default_locale)
        requested_locale = locale || wanted_locale
        @fields[requested_locale] = {} unless @fields[requested_locale]

        default_fields = @fields[default_locale] || {}
        default_fields.merge(@fields[requested_locale])
      end

      # If an entry is a new object gets created in the Contentful, otherwise the existing entry gets updated.
      # @see _ README for details.
      #
      # @return [Contentful::Management::Entry]
      def save
        if id
          update({})
        else
          new_instance = Contentful::Management::Entry.create(
            client,
            content_type.space.id,
            content_type: content_type,
            fields: instance_variable_get(:@fields)
          )
          refresh_data(new_instance)
        end
      end

      # Returns the currently supported local.
      #
      # @return [String] current_locale
      def locale
        sys[:locale] || default_locale
      end

      # Parser for entry attributes from query.
      # Returns a hash of existing fields.
      #
      # @private
      def fields_for_query
        raw_fields = instance_variable_get(:@fields)
        fields_names = flatten_field_names(raw_fields)
        fields_names.each_with_object({}) do |field_name, results|
          results[field_name] = raw_fields.each_with_object({}) do |(locale, fields), field_results|
            field_results[locale] = parse_update_attribute(fields[field_name])
          end
        end
      end

      # @private
      def flatten_field_names(fields)
        without_locales = fields.map { |_, v| v }
        without_locales.map(&:keys).flatten.uniq
      end

      # @private
      def fields_from_attributes(attributes)
        attributes.each do |id, value|
          attributes[id] = { locale => parse_update_attribute(value) }
        end
      end

      protected

      def query_attributes(attributes)
        { fields: Contentful::Management::Support.deep_hash_merge(fields_for_query, fields_from_attributes(attributes)) }
      end

      private

      def self.parse_attribute_with_field(attribute, field)
        case field.type
        when ContentType::LINK then
          { sys: { type: field.type, linkType: field.link_type, id: attribute.id } } if attribute
        when ContentType::ARRAY then
          parse_fields_array(attribute)
        when ContentType::LOCATION then
          { lat: attribute.properties[:lat], lon: attribute.properties[:lon] } if attribute
        else
          attribute
        end
      end

      def parse_update_attribute(attribute)
        case attribute
        when Asset
          self.class.hash_with_link_object('Asset', attribute)
        when Entry
          self.class.hash_with_link_object('Entry', attribute)
        when Location
          { lat: attribute.properties[:lat], lon: attribute.properties[:lon] }
        when ::Array
          self.class.parse_fields_array(attribute)
        else
          attribute
        end
      end

      def method_missing(name, *args, &block)
        if content_type.nil?
          fetch_content_type

          Contentful::Management::Resource::FieldAware.create_fields_for_content_type(self)

          return send(name, *args, &block) if respond_to? name
        end

        fail NameError.new("undefined local variable or method `#{name}' for #{self.class}:#{sys[:id]}", name)
      end

      def fetch_content_type
        @content_type ||= ::Contentful::Management::ContentType.find(client, space.id, sys[:contentType].id)
      end

      def self.hash_with_link_object(type, attribute)
        { sys: { type: 'Link', linkType: type, id: attribute.id } }
      end

      def self.parse_fields_array(attributes)
        type = attributes.first.class
        type == String ? attributes : parse_objects_array(attributes)
      end

      def self.parse_objects_array(attributes)
        attributes.each_with_object([]) do |attr, arr|
          arr << case attr
                 when Entry then
                   hash_with_link_object('Entry', attr)
                 when Asset then
                   hash_with_link_object('Asset', attr)
                 when Hash then
                   attr
                 end
        end
      end

      def self.fields_with_locale(content_type, attributes)
        locale = attributes[:locale] || content_type.sys[:space].default_locale
        fields = content_type.properties[:fields]
        field_names = fields.map { |field| field.id.to_sym }
        attributes.keep_if { |key| field_names.include?(key) }

        attributes.each do |id, value|
          field = fields.detect { |f| f.id.to_sym == id.to_sym }
          attributes[id] = { locale => parse_attribute_with_field(value, field) }
        end
      end
    end
  end
end
