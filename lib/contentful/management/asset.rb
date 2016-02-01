require_relative 'resource'
require_relative 'resource/asset_fields'
require_relative 'resource/fields'

module Contentful
  module Management
    # Resource class for Asset.
    # @see _ https://www.contentful.com/developers/documentation/content-management-api/#resources-assets
    class Asset
      include Contentful::Management::Resource
      extend Contentful::Management::Resource::AssetFields
      include Contentful::Management::Resource::Fields
      include Contentful::Management::Resource::SystemProperties
      include Contentful::Management::Resource::Refresher

      # Gets a collection of assets.
      #
      # @param [String] space_id
      # @param [Hash] query Search Options
      # @see _ For complete option list: http://docs.contentfulcda.apiary.io/#reference/search-parameters
      # @option query [String] 'sys.id' Asset ID
      # @option query [String] :mimetype_group Kind of Asset
      # @option query [Integer] :limit
      # @option query [Integer] :skip
      #
      # @return [Contentful::Management::Array<Contentful::Management::Asset>]
      def self.all(space_id, query = {})
        request = Request.new(
          "/#{space_id}/assets",
          query
        )
        response = request.get
        result = ResourceBuilder.new(response, {}, {})
        result.run
      end

      # Gets a collection of published assets.
      #
      # @param [String] space_id
      # @param [Hash] query Search Options
      # @see _ For complete option list: http://docs.contentfulcda.apiary.io/#reference/search-parameters
      # @option query [String] 'sys.id' Asset ID
      # @option query [String] :mimetype_group Kind of Asset
      # @option query [Integer] :limit
      # @option query [Integer] :skip
      #
      # @return [Contentful::Management::Array<Contentful::Management::Asset>]
      def self.all_published(space_id, query = {})
        request = Request.new(
          "/#{space_id}/public/assets",
          query
        )
        response = request.get
        result = ResourceBuilder.new(response, {}, {})
        result.run
      end

      # Gets a specific asset.
      #
      # @param [String] space_id
      # @param [String] asset_id
      #
      # @return [Contentful::Management::Asset]
      def self.find(space_id, asset_id)
        request = Request.new("/#{space_id}/assets/#{asset_id}")
        response = request.get
        result = ResourceBuilder.new(response, {}, {})
        result.run
      end

      # Creates an asset.
      #
      # @param [String] space_id
      # @param [Hash] attributes
      # @option attributes [String] :title
      # @option attributes [String] :description
      # @option attributes [Contentful::Management::File] :file
      # @option attributes [String] :locale
      # @option attributes [Hash] :fields
      #
      # @see _ README for more information on how to create an Asset
      #
      # @return [Contentful::Management::Asset]
      def self.create(space_id, attributes)
        locale = attributes[:locale]
        asset = new
        asset.instance_variable_set(:@fields, attributes[:fields] || {})
        asset.locale = attributes[:locale] || client.default_locale
        asset.title = attributes[:title] if attributes[:title]
        asset.description = attributes[:description] if attributes[:description]
        asset.file = attributes[:file] if attributes[:file]

        request = Request.new(
          "/#{space_id}/assets/#{attributes[:id]}",
          fields: asset.fields_for_query
        )
        response = attributes[:id].nil? ? request.post : request.put
        result = ResourceBuilder.new(response, {}, {}).run
        result.locale = locale if locale
        result
      end

      # Processing an Asset file
      #
      # @return [Contentful::Management::Asset]
      def process_file
        instance_variable_get(:@fields).keys.each do |locale|
          request = Request.new(
            "/#{space.id}/assets/#{id}/files/#{locale}/process",
            {},
            nil,
            version: sys[:version]
          )
          request.put
        end
        sys[:version] += 1
        self
      end

      # Updates an asset.
      #
      # @param [Hash] attributes
      # @option attributes [String] :title
      # @option attributes [String] :description
      # @option attributes [Contentful::Management::File] :file
      # @option attributes [String] :locale
      #
      # @see _ README for more information on how to create an Asset
      #
      # @return [Contentful::Management::Asset]
      def update(attributes)
        self.title = attributes[:title] if attributes[:title]
        self.description = attributes[:description] if attributes[:description]
        self.file = attributes[:file] if attributes[:file]
        request = Request.new(
          "/#{space.id}/assets/#{id}",
          { fields: fields_for_query },
          nil,
          version: sys[:version]
        )
        response = request.put
        result = ResourceBuilder.new(response, {}, {}).run
        refresh_data(result)
      end

      # If an asset is a new object gets created in the Contentful, otherwise the existing asset gets updated.
      # @see _ https://github.com/contentful/contentful-management.rb for details.
      #
      # @return [Contentful::Management::Asset]
      def save
        if id
          update(title: title, description: description, file: file)
        else
          new_instance = self.class.create(sys[:space].id, fields: instance_variable_get(:@fields))
          refresh_data(new_instance)
        end
      end

      # Destroys an asset.
      #
      # @return [true, Contentful::Management::Error] success
      def destroy
        request = Request.new("/#{space.id}/assets/#{id}")
        response = request.delete
        if response.status == :no_content
          return true
        else
          result = ResourceBuilder.new(response, {}, {})
          result.run
        end
      end

      # Publishes an asset.
      #
      # @return [Contentful::Management::Asset]
      def publish
        request = Request.new(
          "/#{space.id}/assets/#{id}/published",
          {},
          nil,
          version: sys[:version]
        )
        response = request.put
        result = ResourceBuilder.new(response, {}, {}).run
        refresh_data(result)
      end

      # Unpublishes an asset.
      #
      # @return [Contentful::Management::Asset]
      def unpublish
        request = Request.new(
          "/#{space.id}/assets/#{id}/published",
          {},
          nil,
          version: sys[:version]
        )
        response = request.delete
        result = ResourceBuilder.new(response, {}, {}).run
        refresh_data(result)
      end

      # Archive an asset.
      #
      # @return [Contentful::Management::Asset]
      def archive
        request = Request.new(
          "/#{space.id}/assets/#{id}/archived",
          {},
          nil,
          version: sys[:version]
        )
        response = request.put
        result = ResourceBuilder.new(response, {}, {}).run
        refresh_data(result)
      end

      # Unarchvie an asset.
      #
      # @return [Contentful::Management::Asset]
      def unarchive
        request = Request.new(
          "/#{space.id}/assets/#{id}/archived",
          {},
          nil,
          version: sys[:version]
        )
        response = request.delete
        result = ResourceBuilder.new(response, {}, {}).run
        refresh_data(result)
      end

      # Checks if an asset is published.
      #
      # @return [Boolean]
      def published?
        sys[:publishedAt] ? true : false
      end

      # Checks if an asset is archvied.
      #
      # @return [Boolean]
      def archived?
        sys[:archivedAt] ? true : false
      end

      # Returns currently supported local or default locale.
      # @return [String] current_locale
      def locale
        sys && sys[:locale] ? sys[:locale] : default_locale
      end

      # Parser for assets attributes, creates appropriate form of request.
      def fields_for_query
        self.class.fields_coercions.keys.each_with_object({}) do |field_name, results|
          results[field_name] = @fields.each_with_object({}) do |(locale, fields), field_results|
            field_results[locale] = get_value_from(fields, field_name)
          end
        end
      end

      # @private
      def get_value_from(fields, field_name)
        if field_name == :file
          fields[field_name].properties if fields[field_name]
        else
          fields[field_name]
        end
      end

      # Generates a URL for the Contentful Image API
      #
      # @param [Hash] options
      # @option options [Integer] :width
      # @option options [Integer] :height
      # @option options [String] :format
      # @option options [String] :quality
      # @see _ https://www.contentful.com/developers/documentation/content-delivery-api/#image-asset-resizing
      #
      # @return [String] Image API URL
      def image_url(options = {})
        query = {
          w: options[:w] || options[:width],
          h: options[:h] || options[:height],
          fm: options[:fm] || options[:format],
          q: options[:q] || options[:quality]
        }.select { |_k, value| value }

        query.empty? ? file.url : "#{file.url}?#{URI.encode_www_form(query)}"
      end
    end
  end
end
