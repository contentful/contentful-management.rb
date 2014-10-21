module Contentful
  module Management
    module HTTPClient
      def get_http(url, query, headers = {}, proxy = {})
        if proxy[:host]
          HTTP[headers].via(proxy[:host], proxy[:port], proxy[:username], proxy[:password]).get(url, params: query)
        else
          HTTP[headers].get(url, params: query)
        end
      end

      def post_http(url, params, headers = {}, proxy = {})
        if proxy[:host]
          HTTP[headers].via(proxy[:host], proxy[:port], proxy[:username], proxy[:password]).post(url, json: params)
        else
          HTTP[headers].post(url, json: params)
        end
      end

      def delete_http(url, params, headers = {}, proxy = {})
        if proxy[:host]
          HTTP[headers].via(proxy[:host], proxy[:port], proxy[:username], proxy[:password]).delete(url, params: params)
        else
          HTTP[headers].delete(url, params: params)
        end
      end

      def put_http(url, params, headers = {}, proxy = {})
        if proxy[:host]
          HTTP[headers].via(proxy[:host], proxy[:port], proxy[:username], proxy[:password]).put(url, json: params)
        else
          HTTP[headers].put(url, json: params)
        end
      end
    end
  end
  end