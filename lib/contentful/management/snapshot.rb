require_relative 'resource'
require_relative 'client_snapshot_methods_factory'

module Contentful
  module Management
    # Resource class for Snapshot.
    # @see _ https://www.contentful.com/developers/docs/references/content-management-api/#/reference/snapshots
    class Snapshot
      include Contentful::Management::Resource
      include Contentful::Management::Resource::SystemProperties
      include Contentful::Management::Resource::Refresher

      property :snapshot, DynamicEntry

      # Gets all snapshots for an entry
      #
      # @param [Contentful::Management::Client] client
      # @param [String] space_id
      # @param [String] entry_id
      #
      # @return [Contentful::Management::Array<Contentful::Management::Snapshot>]
      def self.all(client, space_id, entry_id)
        ClientSnapshotMethodsFactory.new(client).all(space_id, entry_id)
      end

      # Gets a snapshot by ID
      #
      # @param [Contentful::Management::Client] client
      # @param [String] space_id
      # @param [String] entry_id
      # @param [String] snapshot_id
      #
      # @return [Contentful::Management::Snapshot]
      def self.find(client, space_id, entry_id, snapshot_id)
        ClientSnapshotMethodsFactory.new(client).find(space_id, entry_id, snapshot_id)
      end

      # Not supported
      def self.create(*)
        fail 'Not supported'
      end

      # @private
      def self.endpoint
        'snapshots'
      end

      # @private
      def self.build_endpoint(endpoint_options)
        space_id = endpoint_options.fetch(:space_id)
        entry_id = endpoint_options.fetch(:entry_id)
        snapshot_id = endpoint_options.fetch(:snapshot_id, nil)

        endpoint = "/#{space_id}/entries/#{entry_id}/snapshots"
        endpoint = "#{endpoint}/#{snapshot_id}" unless snapshot_id.nil?

        endpoint
      end

      # Not supported
      def destroy
        fail 'Not supported'
      end

      # Not supported
      def update(*)
        fail 'Not supported'
      end
    end
  end
end
