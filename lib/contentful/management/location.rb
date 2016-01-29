require_relative 'resource'

module Contentful
  module Management
    # Location Field Type
    # @see _ You can directly query for them: https://www.contentful.com/developers/documentation/content-management-api/#search-filter-geo
    class Location
      include Contentful::Management::Resource

      property :lat, :float
      property :lon, :float
    end
  end
end
