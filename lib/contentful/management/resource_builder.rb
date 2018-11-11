require_relative 'link'
require_relative 'user'
require_relative 'role'
require_relative 'error'
require_relative 'entry'
require_relative 'array'
require_relative 'space'
require_relative 'asset'
require_relative 'locale'
require_relative 'upload'
require_relative 'webhook'
require_relative 'api_key'
require_relative 'resource'
require_relative 'snapshot'
require_relative 'api_usage'
require_relative 'environment'
require_relative 'usage_period'
require_relative 'organization'
require_relative 'content_type'
require_relative 'webhook_call'
require_relative 'ui_extension'
require_relative 'dynamic_entry'
require_relative 'webhook_health'
require_relative 'preview_api_key'
require_relative 'space_membership'
require_relative 'editor_interface'
require_relative 'personal_access_token'

module Contentful
  module Management
    # Transforms a Contentful::Response into a Contentful::Resource or a Contentful::Error
    # See example/resource_mapping.rb for avanced usage
    class ResourceBuilder
      # Default Resource Mapping
      # @see _ README for more information on Resource Mapping
      DEFAULT_RESOURCE_MAPPING = {
        'Space' => Contentful::Management::Space,
        'SpaceMembership' => Contentful::Management::SpaceMembership,
        'Organization' => Contentful::Management::Organization,
        'ApiUsage' => Contentful::Management::ApiUsage,
        'UsagePeriod' => Contentful::Management::UsagePeriod,
        'User' => Contentful::Management::User,
        'Environment' => Contentful::Management::Environment,
        'ContentType' => Contentful::Management::ContentType,
        'Entry' => :find_entry_class,
        'Asset' => Contentful::Management::Asset,
        'Array' => :array_or_sync_page,
        'Link' => Contentful::Management::Link,
        'WebhookDefinition' => Contentful::Management::Webhook,
        'WebhookCallOverview' => Contentful::Management::WebhookCall,
        'WebhookCallDetails' => Contentful::Management::WebhookCall,
        'Webhook' => Contentful::Management::WebhookHealth,
        'ApiKey' => Contentful::Management::ApiKey,
        'PreviewApiKey' => Contentful::Management::PreviewApiKey,
        'PersonalAccessToken' => Contentful::Management::PersonalAccessToken,
        'Locale' => Contentful::Management::Locale,
        'Role' => Contentful::Management::Role,
        'Extension' => Contentful::Management::UIExtension,
        'EditorInterface' => Contentful::Management::EditorInterface,
        'Snapshot' => Contentful::Management::Snapshot,
        'Upload' => Contentful::Management::Upload
      }.freeze

      # Default Entry Mapping
      # @see _ README for more information on Entry Mapping
      DEFAULT_ENTRY_MAPPING = {}.freeze

      attr_reader :client, :response, :resource_mapping, :entry_mapping, :resource

      def initialize(response, client, resource_mapping = {}, entry_mapping = {})
        @response = response
        @client = client
        @included_resources = {}
        @known_resources = Hash.new { |hash, key| hash[key] = {} }
        @nested_locales = true
        @default_locale = (client.configuration || Contentful::Management::Client::DEFAULT_CONFIGURATION)[:default_locale]
        @resource_mapping = default_resource_mapping.merge(resource_mapping)
        @entry_mapping = default_entry_mapping.merge(entry_mapping)
      end

      # Starts the parsing process.
      # @return [Contentful::Management::Resource, Contentful::Management::Error]
      def run
        if response.status == :ok
          create_all_resources!
        else
          response.object
        end
      end

      # PARSING MECHANISM
      # - raise error if response not valid
      # - look for included objects and parse them to resources
      # - parse main object to resource
      # - replace links in included resources with known resources
      # - replace links in main resource with known resources
      # - return main resource
      def create_all_resources!
        create_included_resources! response.object['includes']
        @resource = create_resource(response.object)

        unless @included_resources.empty?
          replace_links_in_included_resources_with_known_resources
          replace_links_with_known_resources @resource
        end

        @resource
      rescue UnparsableResource => error
        error
      end

      # Creates a single resource from the response object
      def create_resource(object)
        res_class = detect_resource_class(object)
        @nested_locales ||= res_class.nested_locale_fields?
        res = res_class.new(object, response.request, client, @nested_locales, @default_locale)

        add_to_known_resources res
        replace_children res, object
        replace_child_array res.items if res.array?

        res
      end

      # Checks in a custom class for an entry was defined in entry_mapping
      def find_entry_class(object)
        entry_mapping[content_type_id_for_entry(object)] || try_dynamic_entry(object)
      end

      # Automatically converts Entry to DynamicEntry if in cache
      def try_dynamic_entry(object)
        get_dynamic_entry(object) || Contentful::Management::Entry
      end

      # Finds the proper DynamicEntry class for an entry
      def get_dynamic_entry(object)
        content_id = content_type_id_for_entry(object)
        client.dynamic_entry_cache[content_id.to_sym] if content_id
      end

      # Returns the id of the related ContentType, if there is one
      def content_type_id_for_entry(object)
        object['sys']['contentType']['sys']['id']
      end

      # Detects if a resource is an Contentful::Array or a SyncPage
      def array_or_sync_page(object)
        if object['nextPageUrl'] || object['nextSyncUrl']
          SyncPage
        else
          Array
        end
      end

      # Uses the resource mapping to find the proper Resource class to initialize
      # for this Response object type
      #
      # The mapping value can be a
      # - Class
      # - Proc: Will be called, expected to return the proper Class
      # - Symbol: Will be called as method of the ResourceBuilder itself
      def detect_resource_class(object)
        type = object['sys'] && object['sys']['type']
        case res_class = resource_mapping[type]
        when Symbol
          public_send(res_class, object)
        when Proc
          res_class[object]
        when nil
          fail UnparsableResource, response
        else
          res_class
        end
      end

      # The default mapping for #detect_resource_class
      def default_resource_mapping
        DEFAULT_RESOURCE_MAPPING.dup
      end

      # The default entry mapping
      def default_entry_mapping
        DEFAULT_ENTRY_MAPPING.dup
      end

      private

      def detect_child_objects(object)
        if object.is_a? Hash
          object.select { |_key, value| value.is_a?(Hash) && value.key?('sys') }
        else
          {}
        end
      end

      def detect_child_arrays(object)
        if object.is_a? Hash
          object.select do |_, value|
            value.is_a?(::Array) &&
              value.first &&
              value.first.is_a?(Hash) &&
              value.first.key?('sys')
          end
        else
          {}
        end
      end

      def add_to_known_resources(res)
        @known_resources[res.type][res.id] = res if res.sys && res.id && res.type != 'Link'
      end

      def replace_children(res, object)
        object.each do |name, potential_objects|
          detect_child_objects(potential_objects).each do |child_name, child_object|
            res.public_send(name)[child_name.to_sym] = create_resource(child_object)
          end
          next if name == 'includes'
          detect_child_arrays(potential_objects).each do |child_name, _child_array|
            replace_child_array res.public_send(name)[child_name.to_sym]
          end
        end
      end

      def replace_child_array(child_array)
        child_array.map! { |resource_object| create_resource(resource_object) }
      end

      def create_included_resources!(included_objects)
        return unless included_objects

        included_objects.each do |type, objects|
          @included_resources[type] = Hash[
            objects.map do |object|
              res = create_resource(object)
              [res.id, res]
            end
          ]
        end
      end

      def replace_links_with_known_resources(res, seen_resource_ids = [])
        seen_resource_ids << res.id

        property_containers = %i[properties sys fields].map do |property_container_name|
          res.public_send(property_container_name)
        end.compact

        property_containers.each do |property_container|
          replace_links_in_properties(property_container, seen_resource_ids)
        end

        replace_links_in_array res.items, seen_resource_ids if res.array?
      end

      def replace_links_in_properties(property_container, seen_resource_ids)
        property_container.each do |property_name, property_value|
          if property_value.is_a? ::Array
            replace_links_in_array property_value, seen_resource_ids
          else
            replace_link_or_check_recursively property_value, property_container, property_name, seen_resource_ids
          end
        end
      end

      def replace_links_in_array(property_container, seen_resource_ids)
        property_container.each.with_index do |child_property, property_index|
          replace_link_or_check_recursively child_property, property_container, property_index, seen_resource_ids
        end
      end

      def replace_link_or_check_recursively(property_value, property_container, property_name, seen_resource_ids)
        if property_value.is_a? Link
          maybe_replace_link(property_value, property_container, property_name)
        elsif property_value.is_a?(Resource) && property_value.sys && !seen_resource_ids.include?(property_value.id)
          replace_links_with_known_resources(property_value, seen_resource_ids)
        end
      end

      def maybe_replace_link(link, parent, key)
        return unless @known_resources[link.link_type] &&
                      @known_resources[link.link_type].key?(link.id)

        parent[key] = @known_resources[link.link_type][link.id]
      end

      def replace_links_in_included_resources_with_known_resources
        @included_resources.each do |_, for_type|
          for_type.each do |_, res|
            replace_links_with_known_resources(res)
          end
        end
      end
    end
  end
end
