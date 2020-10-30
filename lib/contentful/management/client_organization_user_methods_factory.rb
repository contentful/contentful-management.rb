require 'contentful/management/organization_user'

module Contentful
  module Management
    # Wrapper for Organization Users for usage from within Client
    # @private
    class ClientOrganizationUserMethodsFactory
      def initialize(client, organization_id)
        @client = client
        @organization_id = organization_id
      end

      def find(user_id)
        OrganizationUser.find(@client, @organization_id, user_id)
      end
    end
  end
end
