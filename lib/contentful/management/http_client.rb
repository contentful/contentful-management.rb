module Contentful
  module Management
    # Thin HTTP Client with Restful Operations
    module HTTPClient
      # Get Request
      #
      # @param [String] url
      # @param [Hash] query
      # @param [Hash] headers
      #
      # @return [HTTP::Response]
      def get_http(url, query, headers = {})
        HTTP[headers].get(url, params: query)
      end

      # Post Request
      #
      # @param [String] url
      # @param [Hash] params
      # @param [Hash] headers
      #
      # @return [HTTP::Response]
      def post_http(url, params, headers = {})
        HTTP[headers].post(url, json: params)
      end

      # Delete Request
      #
      # @param [String] url
      # @param [Hash] params
      # @param [Hash] headers
      #
      # @return [HTTP::Response]
      def delete_http(url, params, headers = {})
        HTTP[headers].delete(url, params: params)
      end

      # Put Request
      #
      # @param [String] url
      # @param [Hash] params
      # @param [Hash] headers
      #
      # @return [HTTP::Response]
      def put_http(url, params, headers = {})
        HTTP[headers].put(url, json: params)
      end
    end
  end
end
