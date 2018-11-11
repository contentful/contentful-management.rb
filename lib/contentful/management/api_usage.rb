require_relative 'resource'

module Contentful
  module Management
    # Resource class for ApiUsage.
    # @see _ https://www.contentful.com/developers/docs/references/content-management-api/#/reference/api-usages
    class ApiUsage
      include Contentful::Management::Resource
      include Contentful::Management::Resource::Refresher
      include Contentful::Management::Resource::SystemProperties

      property :unitOfMeasure
      property :interval
      property :usage
      property :startDate, :date
      property :endDate, :date

      # @private
      def self.build_endpoint(endpoint_options)
        organization_id = endpoint_options[:organization_id]
        usage_type = endpoint_options[:usage_type]

        "organizations/#{organization_id}/usages/#{usage_type}"
      end

      # Gets all api usage statistics for a given organization and usage type, filtered by usage period and api.
      #
      # @param [Contentful::Management::Client] client
      # @param [String] organization_id
      # @param [String] usage_type
      # @param [Integer] usage_period_id
      # @param [String] api
      # @param [Hash] params
      #
      # @return [Contentful::Management::Array<Contentful::Management::ApiUsage>]
      # rubocop:disable Metrics/ParameterLists
      def self.all(client, organization_id, usage_type, usage_period_id, api, params = {})
        ClientApiUsageMethodsFactory.new(client, organization_id).all(usage_type, usage_period_id, api, params)
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
