require_relative '../file'

module Contentful
  module Management
    module Resource
      # Adds fields logic for [Resource] classes
      module Fields
        # Returns the fields hash for the specified locale
        #
        # @param [String] wanted_locale
        #
        # @return [Hash] localized fields
        def fields(wanted_locale = nil)
          wanted_locale = internal_resource_locale if wanted_locale.nil?
          @fields.fetch(wanted_locale.to_s, {})
        end

        # @private
        def initialize(object = nil, *)
          super
          @fields = {}
          extract_fields_from_object! object if object
        end

        # @private
        def inspect(info = nil)
          if fields.empty?
            super(info)
          else
            super("#{info} @fields=#{fields.inspect}")
          end
        end

        # Create accessors for content type, asset, entry objects.
        def self.included(base)
          base.fields_coercions.keys.each do |name|
            accessor_name = Contentful::Management::Support.snakify(name)
            base.send :define_method, accessor_name do
              fields[name.to_sym]
            end
            base.send :define_method, "#{accessor_name}_with_locales" do
              fields_for_query[name.to_sym]
            end
            base.send :define_method, "#{accessor_name}=" do |value|
              fields[name.to_sym] = value
            end
            base.send :define_method, "#{accessor_name}_with_locales=" do |values|
              values.each do |locale, value|
                @fields[locale] = {} unless @fields[locale]
                @fields[locale][name.to_sym] = value
              end
            end
          end
        end

        private

        def extract_fields_from_object!(object)
          if nested_locale_fields? && !object['fields'].nil?
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
end
