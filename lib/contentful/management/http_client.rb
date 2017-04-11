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
        http_send(:get, url, { params: query }, headers, proxy)
      end

      # Post Request
      #
      # @param [String] url
      # @param [Hash] params
      # @param [Hash] headers
      #
      # @return [HTTP::Response]
      def post_http(url, params, headers = {}, proxy = {})
        if url.include?(Client::DEFAULT_CONFIGURATION[:uploads_url])
          data = { body: params }
        else
          data = { json: params }
        end

        http_send(:post, url, data, headers, proxy)
      end

      # Delete Request
      #
      # @param [String] url
      # @param [Hash] params
      # @param [Hash] headers
      #
      # @return [HTTP::Response]
      def delete_http(url, params, headers = {}, proxy = {})
        http_send(:delete, url, { params: params }, headers, proxy)
      end

      # Put Request
      #
      # @param [String] url
      # @param [Hash] params
      # @param [Hash] headers
      #
      # @return [HTTP::Response]
      def put_http(url, params, headers = {}, proxy = {})
        http_send(:put, url, { json: params }, headers, proxy)
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
        ).public_send(type, url, params)
      end

      # HTTP Helper
      # Abtracts the Proxy/No-Proxy logic
      #
      # @param [Symbol] type
      # @param [String] url
      # @param [Hash] params
      # @param [Hash] headers
      # @param [Hash] proxy
      #
      # @return [HTTP::Response]
      def http_send(type, url, params, headers, proxy)
        return proxy_send(type, url, params, headers, proxy) unless proxy[:host].nil?
        HTTP[headers].public_send(type, url, params)
      end
    end
  end
end
