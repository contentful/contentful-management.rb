require_relative '../resource'

module Contentful

  module Management

    class Locale
      include Contentful::Resource
      include Contentful::Resource::SystemProperties

      property :code, :string
      property :name, :string

      def self.all(space_id)
        request = Request.new("/#{space_id}/locales")
        response = request.get
        result = ResourceBuilder.new(self, response, {'Locale' => Locale}, {})
        result.run
      end

      def self.find(space_id, locale_id)
        request = Request.new("/#{space_id}/locales/#{locale_id}")
        response = request.get
        result = ResourceBuilder.new(self, response, {'Locale' => Locale}, {})
        result.run
      end

    end
  end
end
