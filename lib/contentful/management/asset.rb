require_relative 'resource'
require_relative 'resource/asset_fields'
require_relative 'resource/all_published'
require_relative 'resource/fields'
require_relative 'resource/archiver'
require_relative 'resource/publisher'

module Contentful
  module Management
    # Resource class for Asset.
    # @see _ https://www.contentful.com/developers/documentation/content-management-api/#resources-assets
    class Asset
      include Contentful::Management::Resource
      extend Contentful::Management::Resource::AssetFields
      extend Contentful::Management::Resource::AllPublished
      include Contentful::Management::Resource::Fields
      include Contentful::Management::Resource::SystemProperties
      include Contentful::Management::Resource::Refresher
      include Contentful::Management::Resource::Archiver
      include Contentful::Management::Resource::Publisher

      # @private
      def self.client_association_class
        ClientAssetMethodsFactory
      end

      # @private
      def self.pre_process_params(parameters)
        Support.normalize_select!(parameters)
      end

      # @private
      def self.create_attributes(client, attributes)
        asset = new
        asset.instance_variable_set(:@fields, attributes[:fields] || {})
        asset.locale = attributes[:locale] || client.default_locale
        asset.title = attributes[:title] if attributes[:title]
        asset.description = attributes[:description] if attributes[:description]
        asset.file = attributes[:file] if attributes[:file]

        { fields: asset.fields_for_query }
      end

      # @private
      def after_create(attributes)
        self.locale = attributes[:locale] || client.default_locale
      end

      # Processing an Asset file
      #
      # @return [Contentful::Management::Asset]
      def process_file
        instance_variable_get(:@fields).keys.each do |locale|
          request = Request.new(
            client,
            "spaces/#{space.id}/assets/#{id}/files/#{locale}/process",
            {},
            nil,
            version: sys[:version]
          )
          request.put
        end
        sys[:version] += 1
        self
      end

      # If an asset is a new object gets created in the Contentful, otherwise the existing asset gets updated.
      # @see _ https://github.com/contentful/contentful-management.rb for details.
      #
      # @return [Contentful::Management::Asset]
      def save
        if id
          update(title: title, description: description, file: file)
        else
          new_instance = self.class.create(client, sys[:space].id, fields: instance_variable_get(:@fields))
          refresh_data(new_instance)
        end
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

      protected

      def query_attributes(attributes)
        self.title = attributes[:title] if attributes[:title]
        self.description = attributes[:description] if attributes[:description]
        self.file = attributes[:file] if attributes[:file]

        { fields: fields_for_query }
      end
    end
  end
end
