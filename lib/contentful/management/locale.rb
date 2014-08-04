# -*- encoding: utf-8 -*-
require_relative 'resource'

module Contentful

  module Management

    class Locale
      include Contentful::Management::Resource
      include Contentful::Management::Resource::SystemProperties
      include Contentful::Management::Resource::Refresher

      property :code, :string
      property :name, :string
      property :contentManagementApi, :boolean
      property :contentDeliveryApi, :boolean
      property :publish, :boolean

      def self.all(space_id = nil)
        request = Request.new("/#{ space_id }/locales")
        response = request.get
        result = ResourceBuilder.new(self, response, { 'Locale' => Locale }, {})
        result.run
      end

      def self.create(space_id, attributes)
        request = Request.new("/#{ space_id }/locales", { 'name' => attributes.fetch(:name), 'code' => attributes.fetch(:code) })
        response = request.post
        result = ResourceBuilder.new(self, response, { 'Locale' => Locale }, {})
        result.run
      end

      def self.find(space_id, locale_id)
        request = Request.new("/#{ space_id }/locales/#{ locale_id }")
        response = request.get
        result = ResourceBuilder.new(self, response, { 'Locale' => Locale }, {})
        result.run
      end

      def update(attributes)
        request = Request.new("/#{ space.id }/locales/#{ id }", { 'name' => attributes.fetch(:name) }, id = nil, version: sys[:version])
        response = request.put
        result = ResourceBuilder.new(self, response, { 'Locale' => Locale }, {})
        refresh_data(result.run)
      end
    end
  end
end
