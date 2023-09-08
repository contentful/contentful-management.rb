# frozen_string_literal: true

require_relative 'resource'

module Contentful
  module Management
    # Resource class for SpacePeriodicUsage.
    # @see _ https://www.contentful.com/developers/docs/references/content-management-api/#/reference/usage/space-usage/get-space-usage/console/curl
    class SpacePeriodicUsage
      include Contentful::Management::Resource
      include Contentful::Management::Resource::Refresher
      include Contentful::Management::Resource::SystemProperties

      property :metric, :string
      property :usage, :integer
      property :usagePerDay, :object
      property :unitOfMeasure, :string
      property :dateRange, :object

      # @private
      def self.build_endpoint(endpoint_options)
        organization_id = endpoint_options[:organization_id]

        "organizations/#{organization_id}/space_periodic_usages"
      end

      # Gets all space periodic usages for a given organization.
      #
      # @param [Contentful::Management::Client] client
      # @param [String] organization_id
      # @param [Hash] params
      #
      # @return [Contentful::Management::Array<Contentful::Management::SpacePeriodicUsage>]
      def self.all(client, organization_id, params = {})
        ClientSpacePeriodicUsageMethodsFactory.new(client, organization_id).all(params)
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
