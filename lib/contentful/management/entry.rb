require_relative 'resource'
require_relative 'resource/fields'
require_relative 'resource/archiver'
require_relative 'resource/publisher'
require_relative 'resource_requester'
require_relative 'resource/field_aware'
require_relative 'resource/entry_fields'
require_relative 'resource/environment_aware'
require_relative 'client_entry_methods_factory'
require_relative 'entry_snapshot_methods_factory'

module Contentful
  module Management
    # Resource class for Entry.
    # @see _ https://www.contentful.com/developers/documentation/content-management-api/#resources-entries
    class Entry
      include Contentful::Management::Resource
      extend Contentful::Management::Resource::EntryFields
      include Contentful::Management::Resource::SystemProperties

      include Contentful::Management::Resource::Fields
      include Contentful::Management::Resource::Archiver
      include Contentful::Management::Resource::Publisher
      include Contentful::Management::Resource::Refresher
      include Contentful::Management::Resource::EnvironmentAware

      attr_accessor :content_type

      # @private
      def self.pre_process_params(parameters)
        Support.normalize_select!(parameters)
      end

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
        content_type = attributes.delete(:content_type)
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
      def self.create_headers(_client, attributes, instance = nil)
        content_type = instance.nil? ? attributes[:content_type] : (instance.content_type || instance.sys[:contentType])
        content_type_id = content_type.respond_to?(:id) ? content_type.id : content_type[:id]

        { content_type_id: content_type_id }
      end

      # @private
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

      # @private
      def self.hash_with_link_object(type, attribute)
        { sys: { type: 'Link', linkType: type, id: attribute.id } }
      end

      # @private
      def self.parse_fields_array(attributes)
        type = attributes.first.class
        type == String ? attributes : parse_objects_array(attributes)
      end

      # @private
      def self.parse_objects_array(attributes)
        attributes.each_with_object([]) do |attr, arr|
          if attr.is_a? Entry
            arr << hash_with_link_object('Entry', attr)
          elsif attr.is_a? Asset
            arr << hash_with_link_object('Asset', attr)
          elsif attr.is_a? Hash
            arr << attr
          elsif attr.class.ancestors.map(&:to_s).include?('Contentful::Entry')
            arr << hash_with_link_object('Entry', attr)
          elsif attr.class.ancestors.map(&:to_s).include?('Contentful::Asset')
            arr << hash_with_link_object('Asset', attr)
          end
        end
      end

      # Gets Hash of fields for all locales, with locales at a field level
      #
      # @return [Hash] fields by locale
      def self.fields_with_locale(content_type, attributes)
        locale = attributes[:locale] || content_type.sys[:space].default_locale
        fields = content_type.properties[:fields]
        field_names = fields.map { |field| field.id.to_sym }
        attributes = attributes.keep_if { |key| field_names.include?(key) }

        attributes.each_with_object({}) do |(id, value), result|
          field = fields.detect { |f| f.id.to_sym == id.to_sym }
          result[id] = { locale => parse_attribute_with_field(value, field) }
        end
      end

      # @private
      def after_create(attributes)
        self.locale = attributes[:locale] || client.default_locale
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
      # @param [Boolean] remove_undefined Returns only defined (non-nil) fields if true. This replicates
      # the WebApp logic for empty fields, so that we stay consistent across all our software
      # @private
      def fields_for_query(remove_undefined = true)
        raw_fields = instance_variable_get(:@fields)
        fields_names = flatten_field_names(raw_fields)
        fields_names.each_with_object({}) do |field_name, results|
          results[field_name] = raw_fields.each_with_object({}) do |(locale, fields), field_results|
            attribute_value = parse_update_attribute(fields[field_name])
            field_results[locale] = attribute_value unless attribute_value.nil? && remove_undefined
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

      # Allows manipulation of snapshots in context of the current entry
      # Allows listing all snapshots belonging to this entry and finding one by id.
      # @see _ README for details.
      #
      # @return [Contentful::Management::EntrySnapshotMethodsFactory]
      def snapshots
        EntrySnapshotMethodsFactory.new(self)
      end

      protected

      def query_attributes(attributes)
        { fields: Contentful::Management::Support.deep_hash_merge(fields_for_query, fields_from_attributes(attributes)) }
      end

      private

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

      # rubocop:disable Style/MethodMissing
      def method_missing(name, *args, &block)
        if content_type.nil?
          fetch_content_type

          Contentful::Management::Resource::FieldAware.create_fields_for_content_type(self)

          return send(name, *args, &block) if respond_to? name
        end

        fail NameError.new("undefined local variable or method `#{name}' for #{self.class}:#{sys[:id]}", name)
      end
      # rubocop:enable Style/MethodMissing

      def fetch_content_type
        content_type_id = if sys[:contentType].is_a?(::Contentful::Management::Resource)
                            sys[:contentType].id
                          else
                            sys[:contentType]['sys']['id']
                          end
        space_id = space.is_a?(::Contentful::Management::Resource) ? space.id : space['sys']['id']
        @content_type ||= ::Contentful::Management::ContentType.find(client, space_id, environment_id, content_type_id)
      end
    end
  end
end
