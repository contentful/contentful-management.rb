module Contentful
  module Management
    # Resource class for OrganizationUser.
    # @see _ https://www.contentful.com/developers/docs/references/user-management-api/#/reference/users
    class OrganizationUser
      # @private
      def self.build_endpoint(endpoint_options)
        organization_id = endpoint_options[:organization_id]

        endpoint = "organizations/#{organization_id}/users"
        endpoint += "/#{endpoint_options[:resource_id]}" if endpoint_options[:resource_id]
        endpoint
      end

      def self.find(client, organization_id, resource_id)
        ResourceRequester.new(client, self).find(organization_id: organization_id, resource_id: resource_id)
      end
    end
  end
end
