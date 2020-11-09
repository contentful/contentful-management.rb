module Contentful
  module Management
    # Wrapper for Organization Users for usage from within Client
    # @private
    class OrganizationUserMethodsFactory
      def initialize(client, organization_id)
        @client = client
        @organization_id = organization_id
      end

      def find(id)
        User.find(@client, nil, nil, id, @organization_id)
      end
    end
  end
end
