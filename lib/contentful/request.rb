module Contentful
  # Filthy monkey patch
  class Request
    # Delegates the actual HTTP POST request to the client
    def post
      client.post(self)
    end

    # Delegates the actual HTTP PUT request to the client
    def put
      client.put(self)
    end

    def delete
      client.delete(self)
    end
  end
end
