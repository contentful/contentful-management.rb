module Contentful
  module Management
    # This object represents a request that is to be made. It gets initialized by the client
    # with domain specific logic. The client later uses the Request's #url and #query methods
    # to execute the HTTP request.
    class Request
      attr_reader :client, :type, :query, :id, :endpoint

      def initialize(client, endpoint, query = {}, id = nil, header = {})
        @header = header
        @initial_id = id
        @client = client
        @client.version = header[:version]
        @client.organization_id = header[:organization_id]
        @client.content_type_id = header[:content_type_id]
        @client.zero_length = query.empty?
        @endpoint = endpoint

        @query = normalize_query(query) if query && !query.empty?

        if id
          @type = :single
          @id = URI.escape(id)
        else
          @type = :multi
          @id = nil
        end
      end

      # Returns the final URL, relative to a contentful space
      def url
        "#{@endpoint}#{@type == :single ? "/#{id}" : ''}"
      end

      # Delegates the actual HTTP work to the client
      def get
        client.get(self)
      end

      # Delegates the actual HTTP POST request to the client
      def post
        client.post(self)
      end

      # Delegates the actual HTTP PUT request to the client
      def put
        client.put(self)
      end

      # Delegates the actual HTTP DELETE request to the client
      def delete
        client.delete(self)
      end

      # Returns true if endpoint is an absolute url
      # @return [Boolean]
      def absolute?
        @endpoint.start_with?('http')
      end

      # Returns a new Request object with the same data
      def copy
        self.class.new(@client, @endpoint, @query, @initial_id, @header)
      end

      private

      def normalize_query(query)
        Hash[
          query.map do |key, value|
            [
              key.to_sym,
              value
            ]
          end
        ]
      end
    end
  end
end
