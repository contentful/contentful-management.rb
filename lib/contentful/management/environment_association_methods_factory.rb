require_relative 'resource_requester'

module Contentful
  module Management
    # Wrapper for Environment Association Methods
    # @private
    module EnvironmentAssociationMethodsFactory
      attr_reader :environment

      def initialize(environment)
        @environment = environment
      end

      def all(params = {})
        associated_class.all(environment.client, environment.sys[:space].id, environment.id, params)
      end

      def find(id)
        associated_class.find(environment.client, environment.sys[:space].id, environment.id, id)
      end

      def create(attributes = {})
        associated_class.create(environment.client, environment.sys[:space].id, environment.id, attributes)
      end

      def new
        object = associated_class.new
        object.sys[:space] = environment.space
        object.sys[:environment] = environment
        object.client = environment.client
        object
      end

      def associated_class
        class_name = /\A(.+)Environment(.+)MethodsFactory\z/.match(self.class.name).captures.join
        class_name.split('::').reduce(Object) do |mod, actual_class_name|
          mod.const_get(actual_class_name)
        end
      end
    end
  end
end
