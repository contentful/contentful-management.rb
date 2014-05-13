require 'contentful/management/version'
require 'contentful'
require 'contentful/resource_builder'
require 'contentful/response'
require 'contentful/request'
require_relative '../request'
require 'http'
require 'cgi'

module Contentful
  module Management
    class Client
      attr_reader :access_token, :configuration
      attr_accessor :organization

      DEFAULT_CONFIGURATION = { api_url: 'api.contentful.com',
                                api_version: '1',
                                secure: true
                              }

      def initialize(access_token, configuration = {})
        @configuration = default_configuration.merge(configuration)
        @access_token = access_token
      end

      def api_version
        configuration[:api_version]
      end

      def default_configuration
        DEFAULT_CONFIGURATION.dup
      end

      def self.get_http(url, query, headers = {})
        HTTP[headers].get(url, params: query)
      end

      def self.post_http(url, params, headers = {})
        HTTP[headers].post(url, json: params)
      end

      def spaces
        # TODO: add options
        request = Request.new(self, '')
        response = request.get
        result = ResourceBuilder.new(self, response, {}, {}, 'en-US')

        result.run
      end

      def space(space_id)
        request = Request.new(self, "/#{space_id}")
        response = request.get
        result = ResourceBuilder.new(self, response, {}, {}, 'en-US')

        result.run
      end

      def create_space(name, _locales, organization = nil)
        self.organization = organization unless organization.nil?
        request = Request.new(self, '', create_space_header(name))
        response = request.post
        result = ResourceBuilder.new(self, response, {}, {}, 'en-US')

        result.run
      end

      def create_space_header(name)
        Hash['name', name]
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

      def base_url
        "#{protocol}://#{configuration[:api_url]}/spaces"
      end

      def protocol
        configuration[:secure] ? 'https' : 'http'
      end

      def authentication_header
        Hash['Authorization', "Bearer #{access_token}"]
      end

      def api_header
        Hash['Content-Type', "application/vnd.contentful.management.v#{api_version}+json"]
      end

      def user_agent
        Hash['User-Agent', "RubyContenfulManagementGem/#{Contentful::Management::VERSION}"]
      end

      def organization_header(organization)
        Hash['X-Contentful-Organization', organization]
      end

      def request_headers
        headers = {}
        headers.merge! user_agent
        headers.merge! authentication_header
        headers.merge! api_header
        headers.merge! organization_header(organization) if organization

        headers
      end
    end
  end
end
