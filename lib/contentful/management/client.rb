require 'contentful/management/version'
require 'http'
require 'cgi'

module Contentful
  module Management
    class Client
      attr_accessor :api_version
      attr_reader :access_token

      def initialize(access_token)
        @api_version = 1
        @access_token = access_token
      end

      def authentication_header
        Hash['Authorization', "Bearer #{access_token}"]
      end

      def api_header
        Hash['Content-Type', "application/vnd.contentful.delivery.v#{api_version}+json"]
      end

      def user_agent
        Hash['User-Agent', "RubyContenfulManagementGem/#{Contentful::Management::VERSION}"]
      end

      def request_headers
        headers = {}
        headers.merge! user_agent
        headers.merge! authentication_header
        headers.merge! api_header

        headers
      end
    end
  end
end
