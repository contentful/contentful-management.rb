require_relative 'resource'

module Contentful
  module Management
    # Resource class for Role.
    class Role
      include Contentful::Management::Resource
      include Contentful::Management::Resource::SystemProperties
      include Contentful::Management::Resource::Refresher

      property :name, :string
      property :description, :string
      property :permissions, :hash
      property :policies, :array

      # @private
      def self.create_attributes(_client, attributes)
        {
          'name' => attributes.fetch(:name),
          'description' => attributes.fetch(:description),
          'permissions' => attributes.fetch(:permissions),
          'policies' => attributes.fetch(:policies)
        }
      end

      protected

      def query_attributes(attributes)
        attributes.each_with_object({}) { |(k, v), result| result[k.to_sym] = v }
      end
    end
  end
end
