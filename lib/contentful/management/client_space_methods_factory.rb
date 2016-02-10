require_relative 'resource_requester'

module Contentful
  module Management
    # Wrapper for Space API for usage from within Client
    # @private
    class ClientSpaceMethodsFactory
      attr_reader :client

      def initialize(client)
        @client = client
        @resource_requester = ResourceRequester.new(client, associated_class)
      end

      # Gets a collection of spaces.
      #
      # @return [Contentful::Management::Array<Contentful::Management::Space>]
      def all
        spaces = @resource_requester.all
        client.update_dynamic_entry_cache_for_spaces!(spaces)
        spaces
      end

      # Gets a specific space.
      #
      # @param [String] space_id
      #
      # @return [Contentful::Management::Space]
      def find(space_id)
        space = @resource_requester.find(space_id: space_id)
        client.update_dynamic_entry_cache_for_space!(space) if space.is_a? Space
        space
      end

      # Create a space.
      #
      # @param [Hash] attributes
      # @option attributes [String] :name
      # @option attributes [String] :default_locale
      # @option attributes [String] :organization_id Required if user has more than one organization
      #
      # @return [Contentful::Management::Space]
      def create(attributes)
        associated_class.create(client, attributes)
      end

      def new
        object = associated_class.new
        object.client = client
        object
      end

      def associated_class
        ::Contentful::Management::Space
      end
    end
  end
end
