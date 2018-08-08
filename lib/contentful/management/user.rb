require_relative 'resource'

module Contentful
  module Management
    # Resource class for User.
    # @see _ https://www.contentful.com/developers/docs/references/content-management-api/#/reference/users
    class User
      include Contentful::Management::Resource
      include Contentful::Management::Resource::Refresher
      include Contentful::Management::Resource::SystemProperties

      property :email, :string
      property :lastName, :string
      property :firstName, :string
      property :avatarUrl, :string
      property :activated, :boolean
      property :confirmed, :boolean
      property :signInCount, :integer

      # @private
      def self.build_endpoint(endpoint_options)
        endpoint = 'users'
        endpoint = "#{endpoint}/#{endpoint_options[:resource_id]}" if endpoint_options[:resource_id]
        endpoint
      end
    end
  end
end
