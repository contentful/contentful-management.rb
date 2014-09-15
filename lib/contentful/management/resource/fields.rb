# -*- encoding: utf-8 -*-
require_relative '../file'

module Contentful
  module Management
    module Resource
      module Fields
        def fields(wanted_locale = default_locale)
          requested_locale = locale || wanted_locale
          @fields[requested_locale] = {} unless @fields[requested_locale]
          @fields[requested_locale]
        end

        def initialize(object = nil, *)
          super
          @fields = {}
          extract_fields_from_object! object if object
        end

        def inspect(info = nil)
          if fields.empty?
            super(info)
          else
            super("#{ info } @fields=#{ fields.inspect }")
          end
        end

        # Create accessors for content type, asset, entry objects.
        def self.included(base)
          base.fields_coercions.keys.each { |name|
            accessor_name = Contentful::Management::Support.snakify(name)
            base.send :define_method, accessor_name do
              fields[name.to_sym]
            end
            base.send :define_method, "#{ accessor_name }_with_locales" do
              fields_for_query[name.to_sym]
            end
            base.send :define_method, "#{ accessor_name }=" do |value|
              fields[name.to_sym] = value
            end
            base.send :define_method, "#{ accessor_name }_with_locales=" do |values|
              values.each do |locale, value|
                @fields[locale] = {} if @fields[locale].nil?
                @fields[locale][name.to_sym] = value
              end
            end
          }
        end

        private

        def extract_fields_from_object!(object)
          if nested_locale_fields? && !object['fields'].nil?
            object['fields'].each do |field_name, nested_child_object|
              nested_child_object.each do |object_locale, real_child_object|
                @fields[object_locale] ||= {}
                @fields[object_locale].merge! extract_from_object(
                                                  {field_name => real_child_object}, :fields
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
