require_relative '../resource'
require_relative '../resource/asset_fields'

module Contentful
  module Management
    class Asset
      include Contentful::Resource
      include Contentful::Resource::SystemProperties
      include Contentful::Resource::Refresher

      property :fields, AssetFields

      def self.all(space_id = nil)
        request = Request.new("/#{space_id || Thread.current[:space_id]}/assets")
        response = request.get
        result = ResourceBuilder.new(self, response, {'Asset' => Asset}, {})
        result.run
      end

      def self.find(space_id, asset_id)
        request = Request.new("/#{space_id}/assets/#{asset_id}")
        response = request.get
        result = ResourceBuilder.new(self, response, {'Asset' => Asset}, {})
        result.run
      end

      def self.create(space_id, attributes)
        fields = (attributes[:fields] || []).map(&:properties)
        request = Request.new("/#{space_id}/assets/#{attributes[:id] || ''}", {fields: fields})
        response = attributes[:id].nil? ? request.post : request.put
        result = ResourceBuilder.new(self, response, {'Asset' => Asset}, {})
        result.run
      end

      def destroy
        request = Request.new("/#{space.id}/assets/#{id}")
        response = request.delete
        if response.status == :no_content
          return true
        else
          result = ResourceBuilder.new(self, response, {}, {})
          result.run
        end
      end

      def publish
        request = Request.new("/#{ space.id }/assets/#{ id }/published", {}, nil, sys[:version])
        response = request.put
        result = ResourceBuilder.new(self, response, {'Asset' => Asset}, {}).run
        if result.is_a? self.class
          refresh_data(result)
        else
          result
        end
      end

      def unpublish
        request = Request.new("/#{ space.id }/assets/#{ id }/published", {}, nil, sys[:version])
        response = request.delete
        result = ResourceBuilder.new(self, response, {'Asset' => Asset}, {}).run
        if result.is_a? self.class
          refresh_data(result)
        else
          result
        end
      end

      def archive
        request = Request.new("/#{ space.id }/assets/#{ id }/archived", {}, nil, sys[:version])
        response = request.put
        result = ResourceBuilder.new(self, response, {'Asset' => Asset}, {}).run
        if result.is_a? self.class
          refresh_data(result)
        else
          result
        end
      end

      def unarchive
        request = Request.new("/#{ space.id }/assets/#{ id }/archived", {}, nil, sys[:version])
        response = request.delete
        result = ResourceBuilder.new(self, response, {'Asset' => Asset}, {}).run
        if result.is_a? self.class
          refresh_data(result)
        else
          result
        end
      end

      def published?
        !sys[:publishedAt].nil?
      end

      def archived?
        !sys[:archivedAt].nil?
      end

      # Returns the image url of an asset
      # Allows you to pass in the following options for image resizing:
      #   :width
      #   :height
      #   :format
      #   :quality
      # See https://www.contentful.com/developers/documentation/content-delivery-api/#image-asset-resizing
      def image_url(options = {})
        query = {
            w: options[:w] || options[:width],
            h: options[:h] || options[:height],
            fm: options[:fm] || options[:format],
            q: options[:q] || options[:quality]
        }.reject { |_k, v| v.nil? }

        if query.empty?
          file.url
        else
          "#{file.url}?#{URI.encode_www_form(query)}"
        end
      end
    end
  end
end

