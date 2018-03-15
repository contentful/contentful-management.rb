require_relative 'environment'
require_relative 'resource_requester'

module Contentful
  module Management
    # Wrapper for Environment API for usage from within Client
    # @private
    class ClientEnvironmentMethodsFactory
      attr_reader :client

      def initialize(client, space_id)
        @client = client
        @space_id = space_id
        @resource_requester = ResourceRequester.new(client, associated_class)
      end

      # Gets a collection of environments.
      #
      # @return [Contentful::Management::Array<Contentful::Management::Environment>]
      def all
        @resource_requester.all(
          space_id: @space_id
        )
      end

      # Gets a specific environment.
      #
      # @param [String] environment_id
      #
      # @return [Contentful::Management::Environment]
      def find(environment_id)
        @resource_requester.find(
          space_id: @space_id,
          environment_id: environment_id
        )
      end

      # Create an environment.
      #
      # @param [Hash] attributes
      # @option attributes [String] :name
      #
      # @return [Contentful::Management::Environment]
      def create(attributes)
        associated_class.create(client, @space_id, attributes)
      end

      def new
        object = associated_class.new
        object.client = client
        object
      end

      def associated_class
        ::Contentful::Management::Environment
      end
    end
  end
end
