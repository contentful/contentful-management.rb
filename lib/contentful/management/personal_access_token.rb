require_relative 'resource'

module Contentful
  module Management
    # Resource class for PersonalAccessToken.
    # @see _ https://www.contentful.com/developers/docs/references/content-management-api/#/reference/personal-access-tokens
    class PersonalAccessToken
      include Contentful::Management::Resource
      include Contentful::Management::Resource::Refresher
      include Contentful::Management::Resource::SystemProperties

      property :name, :string
      property :scopes, :array
      property :token, :string
      property :revokedAt, :date

      # @private
      def self.build_endpoint(endpoint_options)
        endpoint = 'users/me/access_tokens'
        endpoint = "#{endpoint}/#{endpoint_options[:resource_id]}" if endpoint_options[:resource_id]
        endpoint = "#{endpoint}#{endpoint_options[:suffix]}" if endpoint_options[:suffix]
        endpoint
      end

      # @private
      def self.create_attributes(_client, attributes)
        attributes
      end

      # Not supported
      def destroy
        fail 'Not supported'
      end

      # Revokes the personal access token.
      def revoke
        ResourceRequester.new(client, self.class).update(
          self,
          resource_id: id,
          suffix: '/revoked'
        )
      end
    end
  end
end
