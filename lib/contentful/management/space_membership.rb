require_relative 'resource'

module Contentful
  module Management
    # Resource class for Space Membership.
    class SpaceMembership
      include Contentful::Management::Resource
      include Contentful::Management::Resource::SystemProperties
      include Contentful::Management::Resource::Refresher

      property :admin, :boolean
      property :roles, :array
      property :user, Link

      # Returns the list of roles for this membership.
      def roles
        (properties[:roles] || []).map { |r| r.is_a?(Link) ? r : Link.new(r, nil, client) }
      end

      # @private
      def self.clean_roles(roles)
        roles.map { |r| r.is_a?(Link) ? r.raw_object : r }
      end

      # @private
      def self.create_attributes(_client, attributes)
        {
          'admin' => attributes['admin'] || attributes.fetch(:admin),
          'roles' => clean_roles(attributes['roles'] || attributes.fetch(:roles)),
          'email' => attributes['email'] || attributes.fetch(:email)
        }
      end

      # @private
      def query_attributes(attributes)
        {
          'admin' => attributes['admin'] || attributes[:admin],
          'roles' => self.class.clean_roles(attributes['roles'] || attributes[:roles])
        }.reject { |_k, v| v.nil? }
      end
    end
  end
end
