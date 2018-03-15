require_relative 'resource'

module Contentful
  module Management
    # Resource class for Upload.
    # @see _ https://www.contentful.com/developers/docs/references/content-management-api/#/reference/uploads
    class Upload
      include Contentful::Management::Resource
      include Contentful::Management::Resource::Refresher
      include Contentful::Management::Resource::SystemProperties

      # @private
      def self.create_headers(_client, _attributes)
        { 'Content-Type' => 'application/octet-stream' }
      end

      # Creates an upload.
      #
      # @param [Contentful::Management::Client] client
      # @param [String] space_id
      # @param [Hash] attributes
      # @see _ README for full attribute list for each resource.
      #
      # @return [Contentful::Management::Upload]
      def self.create(client, space_id, attributes = {})
        super(client, space_id, nil, attributes)
      end

      # Finds an upload by ID.
      #
      # @param [Contentful::Management::Client] client
      # @param [String] space_id
      # @param [String] upload_id
      #
      # @return [Contentful::Management::Upload]
      def self.find(client, space_id, upload_id)
        super(client, space_id, nil, upload_id)
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

      # Gets [Contentful::Management::Link]-like representation of the upload
      # This is used in particular for associating the upload with an asset
      #
      # @return [Hash] link-like representation of the upload
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
