# -*- encoding: utf-8 -*-
require_relative 'resource'

module Contentful
  module Management
    # Location Field Type
    # You can directly query for them: https://www.contentful.com/developers/documentation/content-delivery-api/#search-filter-geo
    class Location
      include Contentful::Management::Resource

      property :lat, :float
      property :lon, :float
    end
  end
end
