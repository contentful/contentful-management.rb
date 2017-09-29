require 'contentful/management'
require 'contentful/management/response'
require 'contentful/management/resource_builder'

require 'contentful/management/version'
require 'contentful/management/http_client'

require 'contentful/management/client_space_methods_factory'
require 'contentful/management/client_space_membership_methods_factory'
require 'contentful/management/client_api_key_methods_factory'
require 'contentful/management/client_asset_methods_factory'
require 'contentful/management/client_content_type_methods_factory'
require 'contentful/management/client_entry_methods_factory'
require 'contentful/management/client_locale_methods_factory'
require 'contentful/management/client_role_methods_factory'
require 'contentful/management/client_ui_extension_methods_factory'
require 'contentful/management/client_editor_interface_methods_factory'
require 'contentful/management/client_webhook_methods_factory'
require 'contentful/management/client_webhook_call_methods_factory'
require 'contentful/management/client_webhook_health_methods_factory'
require 'contentful/management/client_upload_methods_factory'
require 'contentful/management/client_snapshot_methods_factory'

require_relative 'request'
require 'http'
require 'json'
require 'logger'
require 'rbconfig'

module Contentful
  module Management
    # Client for interacting with the Contentful Management API
    # @see _ https://www.contentful.com/developers/docs/references/content-management-api/
    class Client
      extend Contentful::Management::HTTPClient

      attr_reader :access_token, :configuration, :logger
      attr_accessor :organization_id, :version, :content_type_id, :dynamic_entry_cache

      # Default configuration for Contentful::Management::Client
      DEFAULT_CONFIGURATION = {
        api_url: 'api.contentful.com',
        uploads_url: 'upload.contentful.com',
        api_version: '1',
        secure: true,
        default_locale: 'en-US',
        gzip_encoded: false,
        logger: false,
        log_level: Logger::INFO,
        raise_errors: false,
        dynamic_entries: [],
        disable_content_type_caching: false,
        proxy_host: nil,
        proxy_port: nil,
        proxy_username: nil,
        proxy_password: nil,
        max_rate_limit_retries: 1,
        max_rate_limit_wait: 60,
        application_name: nil,
        application_version: nil,
        integration_name: nil,
        integration_version: nil
      }.freeze

      # Rate Limit Reset Header Key
      RATE_LIMIT_RESET_HEADER_KEY = 'x-contentful-ratelimit-reset'.freeze

      # @param [String] access_token
      # @param [Hash] configuration
      # @option configuration [String] :api_url
      # @option configuration [String] :api_version
      # @option configuration [String] :default_locale
      # @option configuration [Boolean] :gzip_encoded
      # @option configuration [false, ::Logger] :logger
      # @option configuration [::Logger::DEBUG, ::Logger::INFO, ::Logger::WARN, ::Logger::ERROR] :log_level
      # @option configuration [Boolean] :raise_errors
      # @option configuration [::Array<String>] :dynamic_entries
      # @option configuration [Boolean] :disable_content_type_caching
      # @option configuration [String] :proxy_host
      # @option configuration [Fixnum] :proxy_port
      # @option configuration [String] :proxy_username
      # @option configuration [String] :proxy_username
      # @option configuration [String] :application_name
      # @option configuration [String] :application_version
      # @option configuration [String] :integration_name
      # @option configuration [String] :integration_version
      def initialize(access_token = nil, configuration = {})
        @configuration = default_configuration.merge(configuration)
        setup_logger
        @access_token = access_token
        @dynamic_entry_cache = {}
        Thread.current[:client] = self
        update_all_dynamic_entry_cache!
      end

      # Allows manipulation of spaces in context of the current client
      # Allows listing all spaces for client and finding one by ID.
      # @see _ README for details.
      #
      # @return [Contentful::Management::ClientSpaceMethodsFactory]
      def spaces
        ClientSpaceMethodsFactory.new(self)
      end

      # Allows manipulation of space memberships in context of the current client
      # Allows listing all space memberships for client, creating new and finding one by ID.
      # @see _ README for details.
      #
      # @return [Contentful::Management::ClientSpaceMembershipMethodsFactory]
      def space_memberships
        ClientSpaceMembershipMethodsFactory.new(self)
      end

      # Allows manipulation of api keys in context of the current client
      # Allows listing all api keys for client, creating new and finding one by ID.
      # @see _ README for details.
      #
      # @return [Contentful::Management::ClientApiKeyMethodsFactory]
      def api_keys
        ClientApiKeyMethodsFactory.new(self)
      end

      # Allows manipulation of assets in context of the current client
      # Allows listing all assets for client, creating new and finding one by ID.
      # @see _ README for details.
      #
      # @return [Contentful::Management::ClientAssetMethodsFactory]
      def assets
        ClientAssetMethodsFactory.new(self)
      end

      # Allows manipulation of content types in context of the current client
      # Allows listing all content types for client, creating new and finding one by ID.
      # @see _ README for details.
      #
      # @return [Contentful::Management::ClientContentTypeMethodsFactory]
      def content_types
        ClientContentTypeMethodsFactory.new(self)
      end

      # Allows manipulation of entries in context of the current client
      # Allows listing all entries for client, creating new and finding one by ID.
      # @see _ README for details.
      #
      # @return [Contentful::Management::ClientEntryMethodsFactory]
      def entries
        ClientEntryMethodsFactory.new(self)
      end

      # Allows manipulation of locales in context of the current client
      # Allows listing all locales for client, creating new and finding one by ID.
      # @see _ README for details.
      #
      # @return [Contentful::Management::ClientLocaleMethodsFactory]
      def locales
        ClientLocaleMethodsFactory.new(self)
      end

      # Allows manipulation of roles in context of the current client
      # Allows listing all roles for client, creating new and finding one by ID.
      # @see _ README for details.
      #
      # @return [Contentful::Management::ClientRoleMethodsFactory]
      def roles
        ClientRoleMethodsFactory.new(self)
      end

      # Allows manipulation of UI extensions in context of the current client
      # Allows listing all UI extensions for client, creating new and finding one by ID.
      # @see _ README for details.
      #
      # @return [Contentful::Management::ClientUIExtensionMethodsFactory]
      def ui_extensions
        ClientUIExtensionMethodsFactory.new(self)
      end

      # Allows manipulation of editor interfaces in context of the current client
      # Allows listing all editor interfaces for client and finding one by content type.
      # @see _ README for details.
      #
      # @return [Contentful::Management::ClientEditorInterfaceMethodsFactory]
      def editor_interfaces
        ClientEditorInterfaceMethodsFactory.new(self)
      end

      # Allows manipulation of webhooks in context of the current client
      # Allows listing all webhooks for client, creating new and finding one by ID.
      # @see _ README for details.
      #
      # @return [Contentful::Management::ClientWebhookMethodsFactory]
      def webhooks
        ClientWebhookMethodsFactory.new(self)
      end

      # Allows manipulation of webhook calls in context of the current client
      # Allows listing all webhook call details for client and finding one by ID.
      # @see _ README for details.
      #
      # @return [Contentful::Management::ClientWebhookCallMethodsFactory]
      def webhook_calls
        ClientWebhookCallMethodsFactory.new(self)
      end

      # Allows manipulation of webhook health in context of the current client
      # Allows listing all webhook health details for client and finding one by ID.
      # @see _ README for details.
      #
      # @return [Contentful::Management::ClientWebhookHealthMethodsFactory]
      def webhook_health
        ClientWebhookHealthMethodsFactory.new(self)
      end

      # Allows manipulation of uploads in context of the current client
      # Allows creating new and finding uploads by ID.
      # @see _ README for details.
      #
      # @return [Contentful::Management::ClientUploadMethodsFactory]
      def uploads
        ClientUploadMethodsFactory.new(self)
      end

      # Allows manipulation of snapshots in context of the current client
      # Allows listing all snapshots for client and finding one by ID.
      # @see _ README for details.
      #
      # @return [Contentful::Management::ClientSnapshotMethodsFactory]
      def snapshots(resource_type = 'entries')
        ClientSnapshotMethodsFactory.new(self, resource_type)
      end

      # Allows manipulation of entry snapshots in context of the current client
      # Allows listing all entry snapshots for client and finding one by ID.
      # @see _ README for details.
      #
      # @return [Contentful::Management::ClientSnapshotMethodsFactory]
      def entry_snapshots
        ClientSnapshotMethodsFactory.new(self, 'entries')
      end

      # Allows manipulation of content type snapshots in context of the current client
      # Allows listing all content type snapshots for client and finding one by ID.
      # @see _ README for details.
      #
      # @return [Contentful::Management::ClientSnapshotMethodsFactory]
      def content_type_snapshots
        ClientSnapshotMethodsFactory.new(self, 'content_types')
      end

      # @private
      def setup_logger
        @logger = configuration[:logger]
        logger.level = configuration[:log_level] if logger
      end

      # @private
      def update_all_dynamic_entry_cache!
        return if configuration[:dynamic_entries].empty? || configuration[:disable_content_type_caching]

        spaces = configuration[:dynamic_entries].map { |space_id| ::Contentful::Management::Space.find(self, space_id) }
        update_dynamic_entry_cache_for_spaces!(spaces)
      end

      # @private
      def update_dynamic_entry_cache_for_spaces!(spaces)
        return if configuration[:disable_content_type_caching]

        spaces.each do |space|
          update_dynamic_entry_cache_for_space!(space)
        end
      end

      # Use this method together with the client's :dynamic_entries configuration.
      # See README for details.
      # @private
      def update_dynamic_entry_cache_for_space!(space)
        return if configuration[:disable_content_type_caching]

        update_dynamic_entry_cache!(space.content_types.all)
      end

      # @private
      def update_dynamic_entry_cache!(content_types)
        content_types.each do |ct|
          @dynamic_entry_cache[ct.id.to_sym] = DynamicEntry.create(ct, self)
        end
      end

      # @private
      def api_version
        configuration[:api_version]
      end

      # @private
      def gzip_encoded
        configuration[:gzip_encoded]
      end

      # @private
      def default_configuration
        DEFAULT_CONFIGURATION.dup
      end

      # @private
      def register_dynamic_entry(key, klass)
        @dynamic_entry_cache[key.to_sym] = klass
      end

      # @private
      def execute_request(request)
        retries_left = configuration[:max_rate_limit_retries]
        host = host_url(request)
        url = request.absolute? ? request.url : host + request.url

        begin
          logger.info(request: { url: url, query: request.query, header: request_headers(request) }) if logger
          raw_response = yield(url)
          logger.debug(response: raw_response) if logger
          clear_headers
          result = Response.new(raw_response, request)
          fail result.object if result.object.is_a?(Error) && configuration[:raise_errors]
        rescue Contentful::Management::RateLimitExceeded => rate_limit_error
          reset_time = rate_limit_error.response.raw[RATE_LIMIT_RESET_HEADER_KEY].to_i
          if should_retry(retries_left, reset_time, configuration[:max_rate_limit_wait])
            retries_left -= 1
            logger.info(retry_message(retries_left, reset_time)) if logger
            sleep(reset_time * Random.new.rand(1.0..1.2))
            retry
          end

          raise
        end

        result
      end

      # @private
      def host_url(request)
        (%r{^/[\w|-]+/uploads(?:/[\w|-]*)?$} =~ request.url) ? uploads_url : base_url
      end

      # @private
      def retry_message(retries_left, reset_time)
        retry_message = 'Contentful Management API Rate Limit Hit! '
        retry_message += "Retrying - Retries left: #{retries_left}"
        retry_message += "- Time until reset (seconds): #{reset_time}"

        retry_message
      end

      # @private
      def should_retry(retries_left, reset_time, max_wait)
        retries_left > 0 && max_wait > reset_time
      end

      # @private
      def clear_headers
        self.content_type_id = nil
        self.version = nil
        self.organization_id = nil
      end

      # @private
      def delete(request)
        execute_request(request) do |url|
          self.class.delete_http(url, {}, request_headers(request), proxy_parameters)
        end
      end

      # @private
      def get(request)
        execute_request(request) do |url|
          self.class.get_http(url, request.query, request_headers(request), proxy_parameters)
        end
      end

      # @private
      def post(request)
        execute_request(request) do |url|
          self.class.post_http(url, request.query, request_headers(request), proxy_parameters)
        end
      end

      # @private
      def put(request)
        execute_request(request) do |url|
          self.class.put_http(url, request.query, request_headers(request), proxy_parameters)
        end
      end

      # @private
      def base_url
        "#{protocol}://#{configuration[:api_url]}/spaces"
      end

      # @private
      def uploads_url
        "#{protocol}://#{configuration[:uploads_url]}/spaces"
      end

      # @private
      def default_locale
        configuration[:default_locale]
      end

      # @private
      def protocol
        configuration[:secure] ? 'https' : 'http'
      end

      # @private
      def authentication_header
        Hash['Authorization', "Bearer #{access_token}"]
      end

      # @private
      def api_version_header
        Hash['Content-Type', "application/vnd.contentful.management.v#{api_version}+json"]
      end

      # Returns the formatted part of the X-Contentful-User-Agent header
      # @private
      def format_user_agent_header(key, values)
        header = "#{key} #{values[:name]}"
        header = "#{header}/#{values[:version]}" if values[:version]
        "#{header};"
      end

      # Returns the X-Contentful-User-Agent sdk data
      # @private
      def sdk_info
        { name: 'contentful-management.rb', version: ::Contentful::Management::VERSION }
      end

      # Returns the X-Contentful-User-Agent app data
      # @private
      def app_info
        { name: configuration[:application_name], version: configuration[:application_version] }
      end

      # Returns the X-Contentful-User-Agent integration data
      # @private
      def integration_info
        { name: configuration[:integration_name], version: configuration[:integration_version] }
      end

      # Returns the X-Contentful-User-Agent platform data
      # @private
      def platform_info
        { name: 'ruby', version: RUBY_VERSION }
      end

      # Returns the X-Contentful-User-Agent os data
      # @private
      def os_info
        os_name = case ::RbConfig::CONFIG['host_os']
                  when /(cygwin|mingw|mswin|windows)/i then 'Windows'
                  when /(darwin|macruby|mac os)/i      then 'macOS'
                  when /(linux|bsd|aix|solarix)/i      then 'Linux'
                  end
        { name: os_name, version: Gem::Platform.local.version }
      end

      # Returns the X-Contentful-User-Agent
      # @private
      def contentful_user_agent
        header = {
          'sdk' => sdk_info,
          'app' => app_info,
          'integration' => integration_info,
          'platform' => platform_info,
          'os' => os_info
        }

        result = []
        header.each do |key, values|
          next unless values[:name]
          result << format_user_agent_header(key, values)
        end

        result.join(' ')
      end

      # @private
      def user_agent
        Hash['X-Contentful-User-Agent', contentful_user_agent]
      end

      # @private
      def organization_header(organization_id)
        Hash['X-Contentful-Organization', organization_id]
      end

      # @private
      def version_header(version)
        Hash['X-Contentful-Version', version]
      end

      # @private
      def content_type_header(content_type_id)
        Hash['X-Contentful-Content-Type', content_type_id]
      end

      # @private
      def accept_encoding_header(encoding)
        Hash['Accept-Encoding', encoding]
      end

      # @todo headers should be supplied differently, maybe through the request object.
      # @private
      def request_headers(request = nil)
        headers = {}
        headers.merge! user_agent
        headers.merge! authentication_header
        headers.merge! api_version_header
        headers.merge! organization_header(organization_id) if organization_id
        headers.merge! version_header(version) if version
        headers.merge! content_type_header(content_type_id) if content_type_id
        headers.merge! accept_encoding_header('gzip') if gzip_encoded

        headers.merge! request.headers unless request.nil?
        headers
      end

      # @private
      def self.shared_instance
        Thread.current[:client]
      end

      # @private
      def proxy_parameters
        {
          host: configuration[:proxy_host],
          port: configuration[:proxy_port],
          username: configuration[:proxy_username],
          password: configuration[:proxy_password]
        }
      end
    end
  end
end
