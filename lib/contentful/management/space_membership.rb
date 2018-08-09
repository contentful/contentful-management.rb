require_relative 'resource'

module Contentful
  module Management
    # Resource class for Space Membership.
    class SpaceMembership
      include Contentful::Management::Resource
      include Contentful::Management::Resource::Refresher
      include Contentful::Management::Resource::SystemProperties

      property :user, Link
      property :roles, :array
      property :admin, :boolean

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

      # Creates an Space Membership
      #
      # @param [Contentful::Management::Client] client
      # @param [String] space_id
      # @param [Hash] attributes
      # @see _ README for full attribute list for each resource.
      #
      # @return [Contentful::Management::SpaceMembership]
      def self.create(client, space_id, attributes = {})
        super(client, space_id, nil, attributes)
      end

      # Finds an Space Membership by ID.
      #
      # @param [Contentful::Management::Client] client
      # @param [String] space_id
      # @param [String] space_membership_id
      #
      # @return [Contentful::Management::SpaceMembership]
      def self.find(client, space_id, space_membership_id)
        super(client, space_id, nil, space_membership_id)
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
