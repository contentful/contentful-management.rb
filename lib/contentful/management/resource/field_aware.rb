module Contentful
  module Management
    module Resource
      # Module for creating Fields based off of ContentTypes
      module FieldAware
        # Creates fields for entry based on it's ContentType
        #
        # @param [Entry] entry the expected entry to modify
        def self.create_fields_for_content_type(entry, method = :instance)
          entry.content_type.fields.each do |field|
            accessor_name = Support.snakify(field.id)

            FieldAware.create_getter(entry, accessor_name, field, method)
            FieldAware.create_setter(entry, accessor_name, field, method)
          end
        end

        # Creates getters for field
        # @private
        def self.create_getter(entry, accessor_name, field, method)
          entry.send("#{method}_eval") do
            send(FieldAware.define(method), accessor_name) do
              fields[field.id.to_sym]
            end

            send(FieldAware.define(method), "#{accessor_name}_with_locales") do
              fields_for_query(false)[field.id.to_sym]
            end
          end
        end

        # Creates setters for field
        # @private
        def self.create_setter(entry, accessor_name, field, method)
          entry.send("#{method}_eval") do
            send(FieldAware.define(method), "#{accessor_name}=") do |value|
              FieldAware.create_setter_field(self, field, value, locale, default_locale)
            end

            send(FieldAware.define(method), "#{accessor_name}_with_locales=") do |values|
              values.each do |locale, value|
                FieldAware.create_setter_field(self, field, value, locale, default_locale)
              end
            end
          end
        end

        # Sets fields with value for locale
        # @private
        def self.create_setter_field(entry, field, value, locale, default_locale)
          fields = entry.instance_variable_get(:@fields)

          return unless localized_or_default_locale(field, default_locale, locale)

          fields[locale] ||= {}
          fields[locale][field.id.to_sym] = value
        end

        # Verifies if field is localized or default locale matches current locale
        #
        # @param [Field] field an entry field
        # @param [String] default_locale
        # @param [String] locale
        #
        # @return [Boolean]
        def self.localized_or_default_locale(field, default_locale, locale)
          field.localized || default_locale == locale
        end

        # @private
        def self.define(class_or_instance)
          "define_#{class_or_instance == :instance ? 'singleton_' : ''}method"
        end
      end
    end
  end
end
