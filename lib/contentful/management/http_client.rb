module Contentful
  module Management
    module HTTPClient
      def get_http(url, query, headers = {})
        HTTP[headers].get(url, params: query)
      end

      def post_http(url, params, headers = {})
        HTTP[headers].post(url, json: params)
      end

      def delete_http(url, params, headers = {})
        HTTP[headers].delete(url, params: params)
      end
    end
  end
end
