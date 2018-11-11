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

      def all(endpoint_options = {}, query = {}, headers = {})
        query = resource_class.pre_process_params(query)
        get(endpoint_options, query, headers)
      end

      def find(endpoint_options = {})
        get(endpoint_options)
      end

      def create(endpoint_options = {}, attributes = {})
        custom_id = attributes.is_a?(Hash) ? attributes[:id] : nil
        request = Request.new(
          client,
          resource_class.build_endpoint(endpoint_options),
          resource_class.create_attributes(client, attributes.clone),
          nil,
          resource_class.create_headers(client, attributes)
        )
        response = custom_id.nil? ? request.post : request.put
        resource = ResourceBuilder.new(response, client).run
        resource.after_create(attributes) if resource_class?(resource)
        resource
      end

      def update(object, endpoint_options = {}, attributes = {}, headers = {})
        object.refresh_data(put(endpoint_options, attributes, headers, object))
      end

      def destroy(endpoint_options = {})
        delete(endpoint_options)
      end

      def archive(object, endpoint_options = {}, headers = {})
        update(object, endpoint_options, {}, headers)
      end
      alias publish archive

      def unarchive(object, endpoint_options = {}, headers = {})
        object.refresh_data(delete(endpoint_options, {}, headers))
      end
      alias unpublish unarchive

      private

      def resource_class?(object)
        object.resource?
      rescue
        false
      end

      def get(endpoint_options = {}, query = {}, headers = {})
        request = Request.new(
          client,
          resource_class.build_endpoint(endpoint_options),
          query,
          nil,
          headers
        )
        ResourceBuilder.new(request.get, client).run
      end

      def put(endpoint_options = {}, attributes = {}, headers = {}, object = nil)
        is_update = !object.nil? && object.id
        request = Request.new(
          client,
          resource_class.build_endpoint(endpoint_options),
          attributes,
          nil,
          headers
        )
        ResourceBuilder.new(is_update ? request.put : request.post, client).run
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
