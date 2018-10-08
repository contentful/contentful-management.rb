require_relative 'resource'
require_relative 'resource/fields'
require_relative 'resource/archiver'
require_relative 'resource/publisher'
require_relative 'resource/asset_fields'
require_relative 'resource/environment_aware'

module Contentful
  module Management
    # Resource class for Asset.
    # @see _ https://www.contentful.com/developers/documentation/content-management-api/#resources-assets
    class Asset
      extend Contentful::Management::Resource::AssetFields

      include Contentful::Management::Resource
      include Contentful::Management::Resource::Fields
      include Contentful::Management::Resource::Archiver
      include Contentful::Management::Resource::Refresher
      include Contentful::Management::Resource::Publisher
      include Contentful::Management::Resource::SystemProperties
      include Contentful::Management::Resource::EnvironmentAware

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
        fields = attributes[:fields] || {}
        locale = attributes[:locale] || client.default_locale
        fields[:title] = { locale => attributes[:title] } if attributes[:title]
        fields[:description] = { locale => attributes[:description] } if attributes[:description]
        fields[:file] = { locale => attributes[:file].properties } if attributes[:file]

        { fields: fields }
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
            process_url(locale),
            {},
            nil,
            version: sys[:version]
          )
          request.put
        end
        sys[:version] += 1
        self
      end

      # Returns currently supported locale or default locale.
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

      def process_url(locale_code)
        "spaces/#{space.id}/environments/#{environment_id}/assets/#{id}/files/#{locale_code}/process"
      end

      def query_attributes(attributes)
        self.title = attributes[:title] if attributes[:title]
        self.description = attributes[:description] if attributes[:description]
        self.file = attributes[:file] if attributes[:file]

        { fields: fields_for_query }
      end
    end
  end
end
