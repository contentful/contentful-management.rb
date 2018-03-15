require_relative 'resource_requester'

module Contentful
  module Management
    # Wrapper for Entry manipulation for a specific Content Type
    # @private
    class ContentTypeSnapshotMethodsFactory
      attr_reader :content_type

      # @private
      def initialize(content_type)
        @content_type = content_type
      end

      # Gets all snapshot for a specific content type.
      #
      # @see _ For complete option list: https://www.contentful.com/developers/docs/references/content-management-api/#/reference/snapshots/content-type-snapshots-collection
      #
      # @return [Contentful::Management::Array<Contentful::Management::Snapshot>]
      def all(params = {})
        Snapshot.all(
          content_type.client,
          content_type.space.id,
          content_type.environment_id,
          content_type.id,
          'content_types',
          params
        )
      end

      # Gets a snapshot by ID for a specific content type.
      #
      # @param [String] snapshot_id
      # @see _ For complete option list: https://www.contentful.com/developers/docs/references/content-management-api/#/reference/snapshots/content-type-snapshots-collection
      #
      # @return [Contentful::Management::Array<Contentful::Management::Snapshot>]
      def find(snapshot_id)
        Snapshot.find(
          content_type.client,
          content_type.space.id,
          content_type.environment_id,
          content_type.id,
          snapshot_id,
          'content_types'
        )
      end
    end
  end
end
