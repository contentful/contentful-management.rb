require 'contentful/management'
require 'contentful/response'
require 'contentful/resource_builder'

require 'contentful/management/version'
require 'contentful/management/http_client'

require_relative '../request'
require 'http'
require 'json'

module Contentful
  module Management
    class Client
      extend Contentful::Management::HTTPClient

      attr_reader :access_token, :configuration, :space_id
      attr_accessor :organization_id, :version, :zero_length

      DEFAULT_CONFIGURATION = {
          api_url: 'api.contentful.com',
          api_version: '1',
          secure: true,
          default_locale: 'en-US'
      }

      alias_method :old_configuration, :configuration
      alias_method :old_access_token, :access_token
      alias_method :old_space_id, :space_id

      def initialize(access_token = nil, space_id = nil, configuration = {})
        @configuration = default_configuration.merge(configuration)
        @access_token = access_token || Thread.current[:access_token]
        @space_id = space_id || Thread.current[:space_id]
        Thread.current[:configuration] = @configuration
        Thread.current[:access_token] = @access_token
        Thread.current[:space_id] = @space_id
      end

      def api_version
        configuration[:api_version]
      end

      def default_configuration
        DEFAULT_CONFIGURATION.dup
      end

      def execute_request(request)
        request_url = request.url
        url = request.absolute? ? request_url : base_url + request_url
        raw_response = yield(url)
        Response.new(raw_response, request)
      end

      def delete(request)
        execute_request(request) do |url|
          self.class.delete_http(url, {}, request_headers)
        end
      end

      def get(request)
        execute_request(request) do |url|
          self.class.get_http(url, {}, request_headers)
        end
      end

      def post(request)
        execute_request(request) do |url|
          self.class.post_http(url, request.query, request_headers)
        end
      end

      def put(request)
        execute_request(request) do |url|
          self.class.put_http(url, request.query, request_headers)
        end
      end

      def configuration
        Thread.current[:configuration] || old_configuration
      end

      def access_token
        Thread.current[:access_token] || old_access_token
      end

      def space_id
        Thread.current[:space_id] || old_space_id
      end

      def base_url
        "#{protocol}://#{configuration[:api_url]}/spaces"
      end

      def default_locale
        configuration[:default_locale]
      end

      def protocol
        configuration[:secure] ? 'https' : 'http'
      end

      def authentication_header
        Hash['Authorization', "Bearer #{access_token}"]
      end

      def api_version_header
        Hash['Content-Type', "application/vnd.contentful.management.v#{api_version}+json"]
      end

      def user_agent
        Hash['User-Agent', "RubyContenfulManagementGem/#{Contentful::Management::VERSION}"]
      end

      def organization_header(organization_id)
        Hash['X-Contentful-Organization', organization_id]
      end

      def version_header(version)
        Hash['X-Contentful-Version', version]
      end

      def zero_length_header
        Hash['Content-Length', 0]
      end

      # XXX: headers should be supplied differently, maybe through the request object.
      def request_headers
        headers = {}
        headers.merge! user_agent
        headers.merge! authentication_header
        headers.merge! api_version_header
        headers.merge! organization_header(organization_id) if organization_id
        headers.merge! version_header(version) if version
        headers.merge! zero_length_header if zero_length
        headers
      end
    end
  end
end
