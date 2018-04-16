require_relative 'resource'
require_relative 'resource/array_like'

module Contentful
  module Management
    # Resource Class for Arrays (e.g. search results)
    # @see _ https://www.contentful.com/developers/documentation/content-delivery-api/#arrays
    # @note It also provides an #each method and includes Ruby's Enumerable module (gives you methods like #min, #first, etc)
    class Array
      # @private
      DEFAULT_LIMIT = 100

      include Contentful::Management::Resource
      include Contentful::Management::Resource::ArrayLike
      include Contentful::Management::Resource::SystemProperties

      property :items
      property :skip, :integer
      property :total, :integer
      property :limit, :integer

      # Simplifies pagination
      def next_page
        if request
          new_skip = (skip || 0) + (limit || DEFAULT_LIMIT)
          new_request = request.copy
          new_request.instance_variable_set(:@query, {}) if new_request.query.nil?
          new_request.query[:skip] = new_skip
          response = new_request.get
          ResourceBuilder.new(response, client).run
        else
          false
        end
      end
    end
  end
end
