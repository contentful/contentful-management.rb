require_relative 'resource'

module Contentful
  module Management
    # Resource class for User.
    # @see _ https://www.contentful.com/developers/docs/references/content-management-api/#/reference/users
    class User
      include Contentful::Management::Resource
      include Contentful::Management::Resource::SystemProperties
      include Contentful::Management::Resource::Refresher

      property :firstName, :string
      property :lastName, :string
      property :avatarUrl, :string
      property :email, :string
      property :activated, :boolean
      property :signInCount, :integer
      property :confirmed, :boolean

      # @private
      def self.build_endpoint(endpoint_options)
        endpoint = '/users'
        endpoint = "#{endpoint}/#{endpoint_options[:resource_id]}" if endpoint_options[:resource_id]
        endpoint
      end
    end
  end
end
