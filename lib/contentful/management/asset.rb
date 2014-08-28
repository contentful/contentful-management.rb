# -*- encoding: utf-8 -*-
require_relative 'resource'
require_relative 'resource/asset_fields'
require_relative 'resource/fields'

module Contentful
  module Management
    # Resource class for Asset.
    # https://www.contentful.com/developers/documentation/content-management-api/#resources-assets
    class Asset

      include Contentful::Management::Resource
      extend Contentful::Management::Resource::AssetFields
      include Contentful::Management::Resource::Fields
      include Contentful::Management::Resource::SystemProperties
      include Contentful::Management::Resource::Refresher

      # Gets a collection of assets.
      # Takes an id of space and an optional hash of query options
      # Returns a Contentful::Management::Array of Contentful::Management::Asset.
      def self.all(space_id, query = {})
        request = Request.new("/#{ space_id }/assets", query)
        response = request.get
        result = ResourceBuilder.new(response, {}, {})
        result.run
      end

      # Gets a specific asset.
      # Takes an id of space and asset.
      # Returns a Contentful::Management::Asset.
      def self.find(space_id, asset_id)
        request = Request.new("/#{ space_id }/assets/#{ asset_id }")
        response = request.get
        result = ResourceBuilder.new(response, {}, {})
        result.run
      end

      # Creates an asset.
      # Takes a space id and hash with attributes (title, description, file)
      # Returns a Contentful::Management::Asset.
      def self.create(space_id, attributes)
        locale = attributes[:locale]
        asset = new
        asset.instance_variable_set(:@fields, attributes[:fields] || {})
        asset.locale = attributes[:locale] if attributes[:locale]
        asset.title = attributes[:title] if attributes[:title]
        asset.description = attributes[:description] if attributes[:description]
        asset.file = attributes[:file] if attributes[:file]

        request = Request.new("/#{ space_id }/assets/#{ attributes[:id] || ''}", {fields: asset.fields_for_query})
        response = attributes[:id].nil? ? request.post : request.put
        result = ResourceBuilder.new(response, {}, {}).run
        result.locale = locale if locale
        result
      end

      # Processing an Asset file
      def process
        instance_variable_get(:@fields).keys.each do |locale|
          request = Request.new("/#{ space.id }/assets/#{ id }/files/#{ locale }/process", {}, id = nil, version: sys[:version])
          request.put
        end
        sys[:version] += 1
        self
      end

      # Updates an asset.
      # Takes hash with attributes (title, description, file)
      # Returns a Contentful::Management::Asset.
      def update(attributes)
        self.title = attributes[:title] if attributes[:title]
        self.description = attributes[:description] if attributes[:description]
        self.file = attributes[:file] if attributes[:file]
        request = Request.new("/#{ space.id }/assets/#{ id }", {fields: fields_for_query}, id = nil, version: sys[:version])
        response = request.put
        result = ResourceBuilder.new(response, {}, {}).run
        refresh_data(result)
      end

      # If an asset is a new object gets created in the Contentful, otherwise the existing asset gets updated.
      # See README for details.
      def save
        if id.nil?
          new_instance = self.class.create(sys[:space].id, {fields: instance_variable_get(:@fields)})
          refresh_data(new_instance)
        else
          update(title: title, description: description, file: file)
        end
      end

      # Destroys an asset.
      # Returns true if succeed.
      def destroy
        request = Request.new("/#{ space.id }/assets/#{ id }")
        response = request.delete
        if response.status == :no_content
          return true
        else
          result = ResourceBuilder.new(response, {}, {})
          result.run
        end
      end

      # Publishes an asset.
      # Returns a Contentful::Management::Asset.
      def publish
        request = Request.new("/#{ space.id }/assets/#{ id }/published", {}, id = nil, version: sys[:version])
        response = request.put
        result = ResourceBuilder.new(response, {}, {}).run
        refresh_data(result)
      end

      # Unpublishes an asset.
      # Returns a Contentful::Management::Asset.
      def unpublish
        request = Request.new("/#{ space.id }/assets/#{ id }/published", {}, id = nil, version: sys[:version])
        response = request.delete
        result = ResourceBuilder.new(response, {}, {}).run
        refresh_data(result)
      end

      # Archive an asset.
      # Returns a Contentful::Management::Asset.
      def archive
        request = Request.new("/#{ space.id }/assets/#{ id }/archived", {}, id = nil, version: sys[:version])
        response = request.put
        result = ResourceBuilder.new(response, {}, {}).run
        refresh_data(result)
      end

      # Unarchvie an asset.
      # Returns a Contentful::Management::Asset.
      def unarchive
        request = Request.new("/#{ space.id }/assets/#{ id }/archived", {}, id = nil, version: sys[:version])
        response = request.delete
        result = ResourceBuilder.new(response, {}, {}).run
        refresh_data(result)
      end

      # Checks if an asset is published.
      # Returns true if published.
      def published?
        !sys[:publishedAt].nil?
      end

      # Checks if an asset is archvied.
      # Returns true if archived.
      def archived?
        !sys[:archivedAt].nil?
      end

      # Returns currently supported local or default locale.
      def locale
        sys && sys[:locale] ? sys[:locale] : default_locale
      end

      # Parser for assets attributes, creates appropriate form of request.
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
            w:  options[:w]  || options[:width],
            h:  options[:h]  || options[:height],
            fm: options[:fm] || options[:format],
            q:  options[:q]  || options[:quality]
        }.reject { |k, v| v.nil? }

        if query.empty?
          file.url
        else
          "#{file.url}?#{URI.encode_www_form(query)}"
        end
      end
    end
  end
end
