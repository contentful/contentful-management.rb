require_relative 'resource_requester'

module Contentful
  module Management
    # Wrapper for Entry Association Methods
    # @private
    module EntryAssociationMethodsFactory
      attr_reader :entry

      def initialize(entry)
        @entry = entry
      end

      def all(_params = {})
        associated_class.all(entry.client, entry.sys[:space].id, entry.environment_id, entry.id)
      end

      def find(id)
        associated_class.find(entry.client, entry.sys[:space].id, entry.environment_id, entry.id, id)
      end

      def associated_class
        class_name = /\A(.+)Entry(.+)MethodsFactory\z/.match(self.class.name).captures.join
        class_name.split('::').reduce(Object) do |mod, actual_class_name|
          mod.const_get(actual_class_name)
        end
      end
    end
  end
end
