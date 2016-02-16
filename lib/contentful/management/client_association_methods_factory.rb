require_relative 'resource_requester'

module Contentful
  module Management
    # Wrapper for Space Association Methods
    # @private
    module ClientAssociationMethodsFactory
      attr_reader :client

      def initialize(client)
        @client = client
        @resource_requester = ResourceRequester.new(client, associated_class)
      end

      # Gets a collection of resources.
      #
      # @param [String] space_id
      # @param [Hash] params
      # @see _ For complete option list: http://docs.contentfulcda.apiary.io/#reference/search-parameters
      #
      # @return [Contentful::Management::Array<Contentful::Management::Resource>]
      def all(space_id, params = {})
        associated_class.all(client, space_id, params)
      end

      # Gets a specific resource.
      #
      # @param [String] space_id
      # @param [String] resource_id
      #
      # @return [Contentful::Management::Resource]
      def find(space_id, resource_id)
        associated_class.find(client, space_id, resource_id)
      end

      def create(space_id, attributes)
        associated_class.create(client, space_id, attributes)
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
