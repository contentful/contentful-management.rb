require_relative 'resource'

module Contentful
  module Management
    # Resource class for Role.
    class Role
      include Contentful::Management::Resource
      include Contentful::Management::Resource::Refresher
      include Contentful::Management::Resource::SystemProperties

      property :name, :string
      property :policies, :array
      property :description, :string
      property :permissions, :hash

      # @private
      def self.create_attributes(_client, attributes)
        {
          'name' => attributes.fetch(:name),
          'description' => attributes.fetch(:description),
          'permissions' => attributes.fetch(:permissions),
          'policies' => attributes.fetch(:policies)
        }
      end

      # Creates a role.
      #
      # @param [Contentful::Management::Client] client
      # @param [String] space_id
      # @param [Hash] attributes
      #
      # @return [Contentful::Management::Role]
      def self.create(client, space_id, attributes = {})
        super(client, space_id, nil, attributes)
      end

      # Finds a role by ID.
      #
      # @param [Contentful::Management::Client] client
      # @param [String] space_id
      # @param [String] role_id
      #
      # @return [Contentful::Management::Role]
      def self.find(client, space_id, role_id)
        super(client, space_id, nil, role_id)
      end

      protected

      def query_attributes(attributes)
        attributes.each_with_object({}) { |(k, v), result| result[k.to_sym] = v }
      end

      # @private
      def refresh_find
        self.class.find(client, space.id, id)
      end
    end
  end
end
