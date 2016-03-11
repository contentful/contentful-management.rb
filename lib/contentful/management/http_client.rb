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
      def get_http(url, query, headers = {}, proxy = {})
        return proxy_send(:get, url, { params: query }, headers, proxy) unless proxy[:host].nil?
        HTTP[headers].get(url, params: query)
      end

      # Post Request
      #
      # @param [String] url
      # @param [Hash] params
      # @param [Hash] headers
      #
      # @return [HTTP::Response]
      def post_http(url, params, headers = {}, proxy = {})
        return proxy_send(:post, url, { json: params }, headers, proxy) unless proxy[:host].nil?
        HTTP[headers].post(url, json: params)
      end

      # Delete Request
      #
      # @param [String] url
      # @param [Hash] params
      # @param [Hash] headers
      #
      # @return [HTTP::Response]
      def delete_http(url, params, headers = {}, proxy = {})
        return proxy_send(:delete, url, { params: params }, headers, proxy) unless proxy[:host].nil?
        HTTP[headers].delete(url, params: params)
      end

      # Put Request
      #
      # @param [String] url
      # @param [Hash] params
      # @param [Hash] headers
      #
      # @return [HTTP::Response]
      def put_http(url, params, headers = {}, proxy = {})
        return proxy_send(:delete, url, { json: params }, headers, proxy) unless proxy[:host].nil?
        HTTP[headers].put(url, json: params)
      end

      # Proxy Helper
      #
      # @param [Symbol] type
      # @param [String] url
      # @param [Hash] params
      # @param [Hash] headers
      # @param [Hash] proxy
      #
      # @return [HTTP::Response]
      def proxy_send(type, url, params, headers, proxy)
        HTTP[headers].via(
          proxy[:host],
          proxy[:port],
          proxy[:username],
          proxy[:password]
        ).send(type, url, params)
      end
    end
  end
end
