require_relative 'resource'
require_relative 'resource/environment_aware'
require_relative 'client_snapshot_methods_factory'

module Contentful
  module Management
    # Resource class for Snapshot.
    # @see _ https://www.contentful.com/developers/docs/references/content-management-api/#/reference/snapshots
    class Snapshot
      include Contentful::Management::Resource
      include Contentful::Management::Resource::Refresher
      include Contentful::Management::Resource::SystemProperties
      include Contentful::Management::Resource::EnvironmentAware

      # @private
      def self.property_coercions
        {
          snapshot: lambda do |h|
            case h.fetch('sys', {})['type']
            when 'Entry'
              DynamicEntry.new(h)
            when 'ContentType'
              ContentType.new(h)
            end
          end
        }
      end

      property :snapshot

      # Gets all snapshots for a resource
      #
      # @param [Contentful::Management::Client] client
      # @param [String] space_id
      # @param [String] environment_id
      # @param [String] resource_id
      # @param [String] resource_type
      #
      # @return [Contentful::Management::Array<Contentful::Management::Snapshot>]
      # rubocop:disable Metrics/ParameterLists
      def self.all(client, space_id, environment_id, resource_id, resource_type = 'entries', params = {})
        ClientSnapshotMethodsFactory.new(client, space_id, environment_id, resource_type).all(resource_id, params)
      end

      # Gets a snapshot by ID
      #
      # @param [Contentful::Management::Client] client
      # @param [String] space_id
      # @param [String] environment_id
      # @param [String] resource_id
      # @param [String] snapshot_id
      # @param [String] resource_type
      #
      # @return [Contentful::Management::Snapshot]
      def self.find(client, space_id, environment_id, resource_id, snapshot_id, resource_type = 'entries')
        ClientSnapshotMethodsFactory.new(client, space_id, environment_id, resource_type).find(resource_id, snapshot_id)
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
        resource_type = endpoint_options.fetch(:resource_type, 'entries')
        space_id = endpoint_options.fetch(:space_id)
        environment_id = endpoint_options.fetch(:environment_id)
        resource_id = endpoint_options.fetch(:resource_id)
        snapshot_id = endpoint_options.fetch(:snapshot_id, nil)

        endpoint = "spaces/#{space_id}/environments/#{environment_id}/#{resource_type}/#{resource_id}/snapshots"
        endpoint = "#{endpoint}/#{snapshot_id}" if snapshot_id

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
