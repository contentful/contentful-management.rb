require_relative 'resource_requester'

module Contentful
  module Management
    # Wrapper for Space Association Methods
    # @private
    module SpaceAssociationMethodsFactory
      attr_reader :space

      def initialize(space)
        @space = space
      end

      def all(params = {})
        associated_class.all(space.client, space.id, nil, params)
      end

      def find(id)
        associated_class.find(space.client, space.id, id)
      end

      def create(attributes)
        associated_class.create(space.client, space.id, attributes)
      end

      def new
        object = associated_class.new
        object.sys[:space] = space
        object.client = space.client
        object
      end

      def associated_class
        class_name = /\A(.+)Space(.+)MethodsFactory\z/.match(self.class.name).captures.join
        class_name.split('::').reduce(Object) do |mod, actual_class_name|
          mod.const_get(actual_class_name)
        end
      end
    end
  end
end
