require_relative 'resource'

module Contentful
  module Management
    # Resource class for Locale.
    class Locale
      include Contentful::Management::Resource
      include Contentful::Management::Resource::SystemProperties
      include Contentful::Management::Resource::Refresher

      property :code, :string
      property :name, :string
      property :contentManagementApi, :boolean
      property :contentDeliveryApi, :boolean
      property :publish, :boolean
      property :default, :boolean

      # Gets a collection of locales.
      #
      # @param [String] space_id
      # @param [Hash] _parameters Search Parameters
      # @option _parameters [String] :name
      # @option _parameters [String] :code
      #
      # @return [Contentful::Management::Array<Contentful::Management::Locale>]
      def self.all(space_id = nil, _parameters = {})
        request = Request.new("/#{space_id}/locales")
        response = request.get
        result = ResourceBuilder.new(response, { 'Locale' => Locale }, {})
        result.run
      end

      # Gets a specific locale.
      #
      # @param [String] space_id
      # @param [String] locale_id
      #
      # @return [Contentful::Management::Locale]
      def self.find(space_id, locale_id)
        request = Request.new("/#{space_id}/locales/#{locale_id}")
        response = request.get
        result = ResourceBuilder.new(response, { 'Locale' => Locale }, {})
        result.run
      end

      # Creates a locale.
      #
      # @param [String] space_id
      # @param [Hash] attributes
      # @option attributes [String] :name
      # @option attributes [String] :code
      #
      # @return [Contentful::Management::Locale]
      def self.create(space_id, attributes)
        request = Request.new(
          "/#{space_id}/locales",
          'name' => attributes.fetch(:name),
          'code' => attributes.fetch(:code)
        )
        response = request.post
        result = ResourceBuilder.new(response, { 'Locale' => Locale }, {})
        result.run
      end

      # Updates a locale.
      #
      # @param [Hash] attributes
      # @option attributes [String] :name
      # @option attributes [String] :code
      #
      # @return [Contentful::Management::Locale]
      def update(attributes)
        parameters = {}
        attributes.each { |k, v| parameters[k.to_s] = v }

        request = Request.new(
          "/#{space.id}/locales/#{id}",
          parameters,
          nil,
          version: sys[:version]
        )
        response = request.put
        result = ResourceBuilder.new(response, { 'Locale' => Locale }, {})
        refresh_data(result.run)
      end

      # Deletes a locale.
      #
      # @return [true, Contentful::Management::Error] success
      def destroy
        request = Request.new("/#{space.id}/locales/#{id}")
        response = request.delete
        if response.status == :no_content
          return true
        else
          result = ResourceBuilder.new(response, {}, {})
          result.run
        end
      end
    end
  end
end
