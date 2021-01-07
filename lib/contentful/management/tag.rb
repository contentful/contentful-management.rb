require_relative 'resource'

module Contentful
  module Management
    # Resource Class for Tags
    # https://www.contentful.com/developers/docs/references/content-management-api/#/reference/content-tags
    class Tag
      include Contentful::Management::Resource
      include Contentful::Management::Resource::SystemProperties

      property :name
    end
  end
end
