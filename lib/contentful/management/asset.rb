# -*- encoding: utf-8 -*-
require_relative 'resource'
require_relative 'resource/fields'

module Contentful
  module Management
    class Asset

      FIELDS_COERCIONS = {
          title: :hash,
          description: :hash,
          file: Contentful::Management::File
      }

      def self.fields_coercions
        FIELDS_COERCIONS
      end

      include Contentful::Management::Resource
      include Contentful::Management::Resource::Fields
      include Contentful::Management::Resource::SystemProperties
      include Contentful::Management::Resource::Refresher

      def self.all(space_id)
        request = Request.new("/#{ space_id }/assets")
        response = request.get
        result = ResourceBuilder.new(self, response, {}, {})
        result.run
      end

      def self.find(space_id, asset_id)
        request = Request.new("/#{ space_id }/assets/#{ asset_id }")
        response = request.get
        result = ResourceBuilder.new(self, response, {}, {})
        result.run
      end

      def self.create(space_id, attributes)
        asset = self.new
        asset.instance_variable_set(:@fields, attributes[:fields] || {})
        asset.locale = attributes[:locale] if attributes[:locale]
        asset.title = attributes[:title] if attributes[:title]
        asset.description = attributes[:description] if attributes[:description]
        asset.file = attributes[:file] if attributes[:file]

        request = Request.new("/#{ space_id }/assets/#{ attributes[:id] || ''}", { fields: asset.fields_for_query })
        response = attributes[:id].nil? ? request.post : request.put
        result = ResourceBuilder.new(self, response, {}, {}).run
        result.process_files if result.is_a? self
        result
      end

      def process_files
        instance_variable_get(:@fields).keys.each do |locale|
          request = Request.new("/#{ space.id }/assets/#{ id }/files/#{ locale }/process", {}, id = nil, version: sys[:version])
          request.put
        end
      end

      def update(attributes)
        self.title = attributes[:title] if attributes[:title]
        self.description = attributes[:description] if attributes[:description]
        self.file = attributes[:file] if attributes[:file]
        request = Request.new("/#{ space.id }/assets/#{ id }", { fields: fields_for_query }, id = nil, version: sys[:version])
        response = request.put
        result = ResourceBuilder.new(self, response, {}, {}).run
        refresh_data(result)
      end

      def save
        if id.nil?
          new_instance = self.class.create(self.sys[:space].id, { fields: instance_variable_get(:@fields) })
          refresh_data(new_instance)
        else
          update(title: title, description: description, file: file)
        end
      end

      def destroy
        request = Request.new("/#{ space.id }/assets/#{ id }")
        response = request.delete
        if response.status == :no_content
          return true
        else
          result = ResourceBuilder.new(self, response, {}, {})
          result.run
        end
      end

      def publish
        request = Request.new("/#{ space.id }/assets/#{ id }/published", {}, id = nil, version: sys[:version])
        response = request.put
        result = ResourceBuilder.new(self, response, {}, {}).run
        refresh_data(result)
      end

      def unpublish
        request = Request.new("/#{ space.id }/assets/#{ id }/published", {}, id = nil, version: sys[:version])
        response = request.delete
        result = ResourceBuilder.new(self, response, {}, {}).run
        refresh_data(result)
      end

      def archive
        request = Request.new("/#{ space.id }/assets/#{ id }/archived", {}, id = nil, version: sys[:version])
        response = request.put
        result = ResourceBuilder.new(self, response, {}, {}).run
        refresh_data(result)
      end

      def unarchive
        request = Request.new("/#{ space.id }/assets/#{ id }/archived", {}, id = nil, version: sys[:version])
        response = request.delete
        result = ResourceBuilder.new(self, response, {}, {}).run
        refresh_data(result)
      end

      def published?
        !sys[:publishedAt].nil?
      end

      def archived?
        !sys[:archivedAt].nil?
      end

      def locale
        sys && sys[:locale] ? sys[:locale] : default_locale
      end

      def fields_for_query
        self.class.fields_coercions.keys.each_with_object({}) do |field_name, results|
          results[field_name] = @fields.each_with_object({}) do |(locale, fields), field_results|
            field_results[locale] = field_name == :file ? (fields[field_name] ? fields[field_name].properties : nil) : fields[field_name]
          end
        end
      end

      # Returns the image url of an asset
      # Allows you to pass in the following options for image resizing:
      #   :width
      #   :height
      #   :format
      #   :quality
      # See https://www.contentful.com/developers/documentation/content-delivery-api/#image-asset-resizing
      def image_url(options = {})
        query = {
            w: options[:w] || options[:width],
            h: options[:h] || options[:height],
            fm: options[:fm] || options[:format],
            q: options[:q] || options[:quality]
        }.reject { |_k, v| v.nil? }

        if query.empty?
          file.url
        else
          "#{ file.url }?#{ URI.encode_www_form(query) }"
        end
      end

    end
  end
end

