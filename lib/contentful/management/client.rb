# -*- encoding: utf-8 -*-
require 'contentful/management'
require 'contentful/management/response'
require 'contentful/management/resource_builder'

require 'contentful/management/version'
require 'contentful/management/http_client'

require_relative 'request'
require 'http'
require 'json'

module Contentful
  module Management
    class Client
      extend Contentful::Management::HTTPClient

      attr_reader :access_token, :configuration
      attr_accessor :organization_id, :version, :zero_length, :content_type_id, :dynamic_entry_cache

      DEFAULT_CONFIGURATION = {
          api_url: 'api.contentful.com',
          api_version: '1',
          secure: true,
          default_locale: 'en-US',
          encoded: true
      }

      def initialize(access_token = nil, configuration = {})
        @configuration = default_configuration.merge(configuration)
        @access_token = access_token
        @dynamic_entry_cache = {}
        Thread.current[:client] = self
      end

      def update_dynamic_entry_cache_for_spaces!(spaces)
        spaces.each do |space|
          update_dynamic_entry_cache_for_space!(space)
        end
      end

      # Use this method together with the client's :dynamic_entries configuration.
      # See README for details.
      def update_dynamic_entry_cache_for_space!(space)
        update_dynamic_entry_cache!(space.content_types.all)
      end

      def update_dynamic_entry_cache!(content_types)
        @dynamic_entry_cache = Hash[
            content_types.map do |ct|
              [
                  ct.id.to_sym,
                  DynamicEntry.create(ct)
              ]
            end
        ]
      end

      def api_version
        configuration[:api_version]
      end

      def encoded
        configuration[:encoded]
      end

      def default_configuration
        DEFAULT_CONFIGURATION.dup
      end

      def register_dynamic_entry(key, klass)
        @dynamic_entry_cache[key.to_sym] = klass
      end

      def execute_request(request)
        request_url = request.url
        url = request.absolute? ? request_url : base_url + request_url
        raw_response = yield(url)
        clear_headers
        Response.new(raw_response, request)
      end

      def clear_headers
        self.content_type_id = nil
        self.version = nil
        self.organization_id = nil
      end

      def delete(request)
        execute_request(request) do |url|
          self.class.delete_http(url, {}, request_headers)
        end
      end

      def get(request)
        execute_request(request) do |url|
          self.class.get_http(url, request.query, request_headers)
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

      def base_url
        "#{ protocol }://#{ configuration[:api_url]}/spaces"
      end

      def default_locale
        configuration[:default_locale]
      end

      def protocol
        configuration[:secure] ? 'https' : 'http'
      end

      def authentication_header
        Hash['Authorization', "Bearer #{ access_token }"]
      end

      def api_version_header
        Hash['Content-Type', "application/vnd.contentful.management.v#{ api_version }+json"]
      end

      def user_agent
        Hash['User-Agent', "RubyContenfulManagementGem/#{ Contentful::Management::VERSION }"]
      end

      def organization_header(organization_id)
        Hash['X-Contentful-Organization', organization_id]
      end

      def version_header(version)
        Hash['X-Contentful-Version', version]
      end

      def content_type_header(content_type_id)
        Hash['X-Contentful-Content-Type', content_type_id]
      end

      def zero_length_header
        Hash['Content-Length', 0]
      end

      def accept_encoding_header(encoding)
        Hash['Accept-Encoding', encoding]
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
        headers.merge! content_type_header(content_type_id) if content_type_id
        headers.merge! accept_encoding_header('gzip') if encoded
        headers
      end

      def self.shared_instance
        Thread.current[:client]
      end
    end
  end
end
