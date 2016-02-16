module Contentful
  module Management
    # Generic Resource Request Class
    # @private
    class ResourceRequester
      attr_reader :client, :resource_class

      def initialize(client, resource_class)
        @client = client
        @resource_class = resource_class
      end

      def all(endpoint_options = {}, query = {})
        get(endpoint_options, query)
      end

      def find(endpoint_options = {})
        get(endpoint_options)
      end

      def create(endpoint_options = {}, attributes = {})
        custom_id = attributes[:id]
        request = Request.new(
          client,
          resource_class.build_endpoint(endpoint_options),
          resource_class.create_attributes(client, attributes),
          nil,
          resource_class.create_headers(client, attributes)
        )
        response = custom_id.nil? ? request.post : request.put
        resource = ResourceBuilder.new(response, client).run
        resource.after_create(attributes) if resource_class?(resource)
        resource
      end

      def update(object, endpoint_options = {}, attributes = {}, headers = {})
        object.refresh_data(put(endpoint_options, attributes, headers))
      end

      def destroy(endpoint_options = {})
        delete(endpoint_options)
      end

      def archive(object, endpoint_options = {}, headers = {})
        update(object, endpoint_options, {}, headers)
      end
      alias_method :publish, :archive

      def unarchive(object, endpoint_options = {}, headers = {})
        object.refresh_data(delete(endpoint_options, {}, headers))
      end
      alias_method :unpublish, :unarchive

      private

      def resource_class?(object)
        object.resource?
      rescue
        false
      end

      def get(endpoint_options = {}, query = {})
        request = Request.new(
          client,
          resource_class.build_endpoint(endpoint_options),
          query
        )
        ResourceBuilder.new(request.get, client).run
      end

      def put(endpoint_options = {}, attributes = {}, headers = {})
        request = Request.new(
          client,
          resource_class.build_endpoint(endpoint_options),
          attributes,
          nil,
          headers
        )
        ResourceBuilder.new(request.put, client).run
      end

      def delete(endpoint_options = {}, attributes = {}, headers = {})
        request = Request.new(
          client,
          resource_class.build_endpoint(endpoint_options),
          attributes,
          nil,
          headers
        )
        response = request.delete
        return true if response.status == :no_content
        ResourceBuilder.new(response, client).run
      end
    end
  end
end
