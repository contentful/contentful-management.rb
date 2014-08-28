module Contentful
  module Management
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
        class_name.split('::').inject(Object) do |mod, class_name|
          mod.const_get(class_name)
        end
      end

    end
  end
end