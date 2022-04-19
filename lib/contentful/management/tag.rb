require_relative 'resource'
require_relative 'resource/environment_aware'

module Contentful
  module Management
    # Resource Class for Tags
    # https://www.contentful.com/developers/docs/references/content-management-api/#/reference/content-tags
    class Tag
      include Contentful::Management::Resource
      include Contentful::Management::Resource::Refresher
      include Contentful::Management::Resource::SystemProperties
      include Contentful::Management::Resource::EnvironmentAware

      property :name

      # @private
      def self.create_attributes(_client, attributes)
        return {} if attributes.nil? || attributes.empty?

        {
          'name' => attributes.fetch(:name),
          'sys' => {
            'visibility' => attributes.fetch(:visibility, 'private'),
            'id' => attributes.fetch(:id),
            'type' => 'Tag'
          }
        }
      end

      def destroy
        ResourceRequester.new(client, self.class).destroy(
          { space_id: space.id,
            environment_id: environment_id,
            resource_id: id },
          {},
          version: sys[:version]
        )
      end
    end
  end
end
