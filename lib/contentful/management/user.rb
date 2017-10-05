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

      def self.build_endpoint(_endpoint_options)
        '/users/me'
      end
    end
  end
end
