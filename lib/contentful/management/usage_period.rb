require_relative 'resource'

module Contentful
  module Management
    # Resource class for UsagePeriod.
    # @see _ https://www.contentful.com/developers/docs/references/content-management-api/#/reference/api-usages
    class UsagePeriod
      include Contentful::Management::Resource
      include Contentful::Management::Resource::Refresher
      include Contentful::Management::Resource::SystemProperties

      property :startDate, :date
      property :endDate, :date

      # @private
      def self.build_endpoint(endpoint_options)
        organization_id = endpoint_options[:organization_id]

        "organizations/#{organization_id}/usage_periods"
      end

      # Gets all usage periods for a given organization.
      #
      # @param [Contentful::Management::Client] client
      # @param [String] organization_id
      # @param [Hash] params
      #
      # @return [Contentful::Management::Array<Contentful::Management::UsagePeriod>]
      def self.all(client, organization_id, params = {})
        ClientUsagePeriodMethodsFactory.new(client, organization_id).all(params)
      end

      # Not supported
      def self.find(*)
        fail 'Not supported'
      end

      # @private
      def self.endpoint
        'usages'
      end

      # Not supported
      def self.create(*)
        fail 'Not supported'
      end

      # Not supported
      def destroy
        fail 'Not supported'
      end

      # Not supported
      def update(*)
        fail 'Not supported'
      end
    end
  end
end
