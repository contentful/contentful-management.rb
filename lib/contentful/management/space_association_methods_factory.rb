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
        associated_class.all(space.id, params)
      end

      def find(id)
        associated_class.find(space.id, id)
      end

      def create(attributes)
        associated_class.create(space.id, attributes)
      end

      def new
        object = associated_class.new
        object.sys[:space] = space
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
