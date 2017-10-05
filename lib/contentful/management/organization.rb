require_relative 'resource'

module Contentful
  module Management
    # Resource class for Organization.
    # @see _ https://www.contentful.com/developers/docs/references/content-management-api/#/reference/organizations
    class Organization
      include Contentful::Management::Resource
      include Contentful::Management::Resource::SystemProperties
      include Contentful::Management::Resource::Refresher

      property :name

      # @private
      def self.build_endpoint(_endpoint_options)
        '/organizations'
      end
    end
  end
end
