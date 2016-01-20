module Contentful
  module Management
    module Resource
      module FieldAware
        def self.create_fields_for_content_type(entry)
          entry.instance_eval do
            content_type.fields.each do |field|
              localized_or_default_locale = Contentful::Management::Resource::FieldAware.localized_or_default_locale(
                field,
                default_locale,
                locale
              )

              accessor_name = Support.snakify(field.id)
              define_singleton_method accessor_name do
                fields[field.id.to_sym]
              end
              define_singleton_method "#{ accessor_name }_with_locales" do
                fields_for_query[field.id.to_sym]
              end
              define_singleton_method "#{ accessor_name }=" do |value|
                if localized_or_default_locale
                    @fields[locale] ||= {}
                    @fields[locale][field.id.to_sym] = value
                end
              end
              define_singleton_method "#{ accessor_name }_with_locales=" do |values|
                values.each do |locale, value|
                  if localized_or_default_locale
                    @fields[locale] ||= {}
                    @fields[locale][field.id.to_sym] = value
                  end
                end
              end
            end
          end
        end

        def self.localized_or_default_locale(field, default_locale, locale)
          field.localized || default_locale == locale
        end
      end
    end
  end
end
