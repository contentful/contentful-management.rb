module Contentful
  module Management
    # Wrapper for Users API for usage from within Organization
    # @private
    class OrganizationUserMethodsFactory
      attr_reader :client

      def initialize(client, organization_id)
        @client = client
        @organization_id = organization_id
      end

      def find(id)
        User.find(client, nil, nil, id, @organization_id)
      end

      def all
        User.all(client, nil, nil, {}, @organization_id)
      end
    end
  end
end
