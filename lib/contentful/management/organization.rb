require_relative 'resource'

module Contentful
  module Management
    # Resource class for Organization.
    # @see _ https://www.contentful.com/developers/docs/references/content-management-api/#/reference/organizations
    class Organization
      include Contentful::Management::Resource
      include Contentful::Management::Resource::Refresher
      include Contentful::Management::Resource::SystemProperties

      property :name

      # @private
      def self.build_endpoint(_endpoint_options)
        'organizations'
      end

      # Allows listing all usage periods for organization.
      # @see _ README for details.
      #
      # @return [Contentful::Management::ClientApiUsageMethodsFactory]
      def usage_periods
        ClientApiUsageMethodsFactory.new(client, id)
      end

      # Allows listing all api usage for organization.
      # @see _ README for details.
      #
      # @return [Contentful::Management::ClientApiUsageMethodsFactory]
      def api_usage
        ClientApiUsageMethodsFactory.new(client, id)
      end
    end
  end
end
