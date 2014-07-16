require_relative '../management/file'

module Contentful
  module Resource
    # Special fields for Asset. Don't include together wit Contentful::Resource::Fields
    #
    # It depends on system properties being available
    module AssetFields
      FIELDS_COERCIONS = {
          title: :hash,
          description: :hash,
          file: Contentful::Management::File,
      }

      def fields(wanted_locale = default_locale)
        @fields[locale || wanted_locale]
      end

      def initialize(object, *)
        super
        extract_fields_from_object! object
      end

      def inspect(info = nil)
        if fields.empty?
          super(info)
        else
          super("#{info} @fields=#{fields.inspect}")
        end
      end

      module ClassMethods
        def fields_coercions
          FIELDS_COERCIONS
        end
      end

      def self.included(base)
        base.extend(ClassMethods)

        base.fields_coercions.keys.each { |name|
          base.send :define_method, Contentful::Support.snakify(name) do
            fields[name.to_sym] #[locale || default_locale]
          end
        }
      end

      private

      def extract_fields_from_object!(object)
        @fields = {}

        if nested_locale_fields?
          object['fields'].each do |field_name, nested_child_object|
            nested_child_object.each do |object_locale, real_child_object|
              @fields[object_locale] ||= {}
              @fields[object_locale].merge! extract_from_object(
                                                { field_name => real_child_object }, :fields
                                            )
            end
          end
        else
          @fields[locale || default_locale] = extract_from_object object['fields'], :fields
        end
      end
    end
  end
end
