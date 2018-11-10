require_relative 'client_association_methods_factory'

module Contentful
  module Management
    # Wrapper for Usage Period for usage from within Client
    # @private
    class ClientUsagePeriodMethodsFactory
      include Contentful::Management::ClientAssociationMethodsFactory

      def initialize(client, organization_id)
        super(client)
        @organization_id = organization_id
      end

      def all(params = {})
        @resource_requester.all(
          {
            organization_id: @organization_id
          },
          params,
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
