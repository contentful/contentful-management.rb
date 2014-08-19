# -*- encoding: utf-8 -*-
require_relative 'resource'
require_relative 'resource/array_like'

module Contentful
  module Management
    # Resource Class for Arrays (e.g. search results)
    # https://www.contentful.com/developers/documentation/content-delivery-api/#arrays
    # It also provides an #each method and includes Ruby's Enumerable module (gives you methods like #min, #first, etc)
    class Array
      DEFAULT_LIMIT = 100

      include Contentful::Management::Resource
      include Contentful::Management::Resource::SystemProperties
      include Contentful::Management::Resource::ArrayLike

      property :total, :integer
      property :limit, :integer
      property :skip, :integer
      property :items

      # Simplifies pagination
      def next_page
        if request
          new_skip = (skip || 0) + (limit || DEFAULT_LIMIT)
          new_request = request.copy
          new_request.query[:skip] = new_skip
          response = new_request.get
          result = ResourceBuilder.new(Contentful::Management::Client.shared_instance, response, {}, {})
          result.run
        else
          false
        end
      end
    end
  end
end
