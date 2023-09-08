# frozen_string_literal: true

require_relative 'client_association_methods_factory'

module Contentful
  module Management
    # Wrapper for Space Periodic Usages for usage from within Client
    # @private
    class ClientSpacePeriodicUsageMethodsFactory
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
          params
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
