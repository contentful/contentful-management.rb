require 'contentful/management'
require 'contentful/response'
require 'contentful/resource_builder'

require 'contentful/management/version'
require 'contentful/management/content_type_client'
require 'contentful/management/space_client'
require 'contentful/management/http_client'

require_relative '../request'
require 'http'
require 'json'

module Contentful
  module Management
    class Client
      # include Contentful::Management::SpaceClient
      # include Contentful::Management::ContentTypeClient
      extend Contentful::Management::HTTPClient

      attr_reader :access_token, :configuration
      attr_accessor :organization, :version

      DEFAULT_CONFIGURATION = { api_url: 'api.contentful.com',
                                api_version: '1',
                                secure: true,
                                default_locale: 'en-US'
                              }

      alias :old_configuration :configuration
      alias :old_access_token :access_token

      def initialize(access_token = nil, configuration = {})
        @configuration = default_configuration.merge(configuration)
        @access_token = access_token || Thread.current[:access_token]
        Thread.current[:configuration] = @configuration
        Thread.current[:access_token] = @access_token
      end

      def api_version
        configuration[:api_version]
      end

      def default_configuration
        DEFAULT_CONFIGURATION.dup
      end

      def delete(request)
        request_url = request.url
        url = request.absolute? ? request_url : base_url + request_url
        raw_response = self.class.delete_http(url, {}, request_headers)
        Response.new(raw_response, request)
      end

      def get(request)
        request_url = request.url
        url = request.absolute? ? request_url : base_url + request_url
        raw_response = self.class.get_http(url, {}, request_headers)
        Response.new(raw_response, request)
      end

      def post(request)
        request_url = request.url
        url = request.absolute? ? request_url : base_url + request_url
        raw_response = self.class.post_http(url, request.query, request_headers)
        Response.new(raw_response, request)
      end

      def put(request)
        request_url = request.url
        url = request.absolute? ? request_url : base_url + request_url
        raw_response = self.class.put_http(url, request.query, request_headers)
        Response.new(raw_response, request)
      end

      def configuration
        Thread.current[:configuration] || old_configuration
      end

      def access_token
        Thread.current[:access_token] || old_access_token
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

      # TODO: rename to api_version_header
      def api_header
        Hash['Content-Type', "application/vnd.contentful.management.v#{api_version}+json"]
      end

      def user_agent
        Hash['User-Agent', "RubyContenfulManagementGem/#{Contentful::Management::VERSION}"]
      end

      def organization_header(organization)
        Hash['X-Contentful-Organization', organization]
      end

      def version_header(version)
        Hash['X-Contentful-Version', version]
      end

      def create_space_header(name)
        Hash['name', name]
      end

      # XXX: headers should be supplied differently, maybe through the request object.
      def request_headers
        headers = {}
        headers.merge! user_agent
        headers.merge! authentication_header
        headers.merge! api_header
        headers.merge! organization_header(organization) if organization
        headers.merge! version_header(version) if version

        headers
      end
    end
  end
end
