require_relative 'resource'
require_relative 'location'
require_relative 'resource/fields'

module Contentful
  module Management
    # Wrapper for Entries with Cached Content Types
    class DynamicEntry < Contentful::Management::Entry
      # Coercions from Contentful Types to Ruby native types
      KNOWN_TYPES = {
        'String' => :string,
        'Text' => :string,
        'Symbol' => :string,
        'Integer' => :integer,
        'Float' => :float,
        'Boolean' => :boolean,
        'Date' => :date,
        'Location' => Location
      }.freeze

      # @private
      def self.define_singleton_properties(entry_class, content_type, client)
        entry_class.class_eval do
          define_singleton_method :content_type do
            content_type
          end

          define_singleton_method :client do
            client
          end

          define_singleton_method :fields_coercions do
            Hash[
              content_type.fields.map do |field|
                [field.id.to_sym, KNOWN_TYPES[field.type]]
              end
            ]
          end

          define_singleton_method :to_s do
            "Contentful::Management::DynamicEntry[#{content_type.id}]"
          end

          define_singleton_method :inspect do
            "Contentful::Management::DynamicEntry[#{content_type.id}]"
          end
        end
      end

      # @private
      def self.create(content_type, client)
        unless content_type.is_a? ContentType
          content_type = ContentType.new(content_type)
        end

        Class.new DynamicEntry do
          DynamicEntry.define_singleton_properties(self, content_type, client)
          FieldAware.create_fields_for_content_type(self, :class)
        end
      end
    end
  end
end
