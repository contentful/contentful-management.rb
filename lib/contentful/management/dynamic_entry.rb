require_relative 'resource'
require_relative 'resource/fields'
require_relative 'location'

module Contentful
  module Management
    class DynamicEntry < Contentful::Management::Entry
      KNOWN_TYPES = {
          'String' => :string,
          'Text' => :string,
          'Symbol' => :string,
          'Integer' => :integer,
          'Float' => :float,
          'Boolean' => :boolean,
          'Date' => :date,
          'Location' => Location
      }

      def self.create(content_type)
        unless content_type.is_a? ContentType
          content_type = ContentType.new(content_type)
        end

        fields_coercions = Hash[
            content_type.fields.map do |field|
              [field.id.to_sym, KNOWN_TYPES[field.type]]
            end
        ]

        Class.new DynamicEntry do
          content_type.fields.each do |field|
            accessor_name = Support.snakify(field.id)
            define_method accessor_name do
              fields[field.id.to_sym]
            end
            define_method "#{ accessor_name }_with_locales" do
              fields_for_query[field.id.to_sym]
            end
            define_method "#{ accessor_name }=" do |value|
              if localized_or_default_locale(field, locale)
                  @fields[locale] = {} unless @fields[locale]
                  @fields[locale][field.id.to_sym] = value
              end
            end
            define_method "#{ accessor_name }_with_locales=" do |values|
              values.each do |locale, value|
                if localized_or_default_locale(field, locale)
                  @fields[locale] = {} unless @fields[locale]
                  @fields[locale][field.id.to_sym] = value
                end
              end
            end
          end

          define_singleton_method :fields_coercions do
            fields_coercions
          end

          define_singleton_method :content_type do
            content_type
          end

          define_singleton_method :to_s do
            "Contentful::Management::DynamicEntry[#{ content_type.id }]"
          end

          define_singleton_method :inspect do
            "Contentful::Management::DynamicEntry[#{ content_type.id }]"
          end
        end
      end

      def localized_or_default_locale(field, locale)
        field.localized || default_locale == locale
      end
    end
  end
end
