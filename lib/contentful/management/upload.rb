require_relative 'resource'

module Contentful
  module Management
    # Resource class for Upload.
    # @see _ https://www.contentful.com/developers/docs/references/content-management-api/#/reference/uploads
    class Upload
      include Contentful::Management::Resource
      include Contentful::Management::Resource::SystemProperties
      include Contentful::Management::Resource::Refresher

      # @private
      def self.create_headers(_client, _attributes)
        { 'Content-Type' => 'application/octet-stream' }
      end

      # @private
      def self.create_attributes(_client, path_or_file)
        case path_or_file
        when ::String
          ::File.binread(path_or_file)
        when ::IO
          path_or_file.read
        end
      end

      def to_link_json
        {
          sys: {
            type: 'Link',
            linkType: 'Upload',
            id: id
          }
        }
      end
    end
  end
end
