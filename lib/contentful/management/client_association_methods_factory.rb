require_relative 'resource_requester'

module Contentful
  module Management
    # Wrapper for Space Association Methods
    # @private
    module ClientAssociationMethodsFactory
      attr_reader :client

      def initialize(client, space_id = nil, environment_id = nil)
        @client = client
        @resource_requester = ResourceRequester.new(client, associated_class)
        @space_id = space_id
        @environment_id = environment_id
      end

      # Gets a collection of resources.
      #
      # @param [Hash] params
      # @see _ For complete option list: https://www.contentful.com/developers/docs/references/content-delivery-api/#/reference/search-parameters
      #
      # @return [Contentful::Management::Array<Contentful::Management::Resource>]
      def all(params = {})
        associated_class.all(client, @space_id, @environment_id, params)
      end

      # Gets a specific resource.
      #
      # @param [String] resource_id
      #
      # @return [Contentful::Management::Resource]
      def find(resource_id)
        associated_class.find(client, @space_id, @environment_id, resource_id)
      end

      def create(attributes)
        associated_class.create(client, @space_id, @environment_id, attributes)
      end

      def new
        object = associated_class.new
        object.client = client
        object
      end

      def associated_class
        class_name = /\A(.+)Client(.+)MethodsFactory\z/.match(self.class.name).captures.join
        class_name.split('::').reduce(Object) do |mod, actual_class_name|
          mod.const_get(actual_class_name)
        end
      end
    end
  end
end
