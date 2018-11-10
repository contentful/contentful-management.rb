require_relative 'client_association_methods_factory'

module Contentful
  module Management
    # Wrapper for API Usage for usage from within Client
    # @private
    class ClientApiUsageMethodsFactory
      include Contentful::Management::ClientAssociationMethodsFactory

      def initialize(client, organization_id)
        super(client)
        @organization_id = organization_id
      end

      def all(usage_type, usage_period_id, api, params = {})
        mandatory_params = {
          'filters[usagePeriod]' => usage_period_id,
          'filters[metric]' => api
        }

        @resource_requester.all(
          {
            usage_type: usage_type,
            organization_id: @organization_id
          },
          mandatory_params.merge(params),
          'x-contentful-enable-alpha-feature' => 'usage-insights'
        )
      end

      def new(*)
        fail 'Not supported'
      end

      def find(*)
        fail 'Not supported'
      end

      def create(*)
        fail 'Not supported'
      end
    end
  end
end
