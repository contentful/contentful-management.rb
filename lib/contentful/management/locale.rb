# -*- encoding: utf-8 -*-
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

      # Gets a collection of locales.
      # Takes an id of a space.
      # Returns a Contentful::Management::Array of Contentful::Management::Locale.
      def self.all(space_id = nil, parameters = {})
        request = Request.new("/#{ space_id }/locales")
        response = request.get
        result = ResourceBuilder.new(response, {'Locale' => Locale}, {})
        result.run
      end

      # Gets a specific locale.
      # Takes an id of a space and locale id.
      # Returns a Contentful::Management::Locale.
      def self.find(space_id, locale_id)
        request = Request.new("/#{ space_id }/locales/#{ locale_id }")
        response = request.get
        result = ResourceBuilder.new(response, {'Locale' => Locale}, {})
        result.run
      end

      # Creates a locale.
      # Takes a space id and hash with attributes:
      #   :name
      #   :code
      #   :contentManagementApi
      #   :contentDeliveryApi
      #   :publish
      # Returns a Contentful::Management::Locale.
      def self.create(space_id, attributes)
        request = Request.new("/#{ space_id }/locales", {'name' => attributes.fetch(:name), 'code' => attributes.fetch(:code)})
        response = request.post
        result = ResourceBuilder.new(response, {'Locale' => Locale}, {})
        result.run
      end

      # Updates a locale.
      # Takes a hash with attributes.
      # Returns a Contentful::Management::Locale.
      def update(attributes)
        request = Request.new("/#{ space.id }/locales/#{ id }", {'name' => attributes.fetch(:name)}, id = nil, version: sys[:version])
        response = request.put
        result = ResourceBuilder.new(response, {'Locale' => Locale}, {})
        refresh_data(result.run)
      end
    end
  end
end
