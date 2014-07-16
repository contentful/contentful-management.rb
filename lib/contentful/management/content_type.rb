require_relative '../resource'
require_relative 'field'

module Contentful
  module Management
    class ContentType

      include Contentful::Resource
      include Contentful::Resource::SystemProperties
      include Contentful::Resource::Refresher

      property :name, :string
      property :description, :string
      property :fields, Field
      property :displayField, :string

      def self.all(space_id)
        request = Request.new("/#{ space_id }/content_types")
        response = request.get
        result = ResourceBuilder.new(self, response, {}, {})
        result.run
      end

      def self.find(space_id, content_type_id)
        request = Request.new("/#{space_id}/content_types/#{ content_type_id }")
        response = request.get
        result = ResourceBuilder.new(self, response, {}, {})
        result.run
      end

      def destroy
        request = Request.new("/#{space.id}/content_types/#{id}")
        response = request.delete
        if response.status == :no_content
          return true
        else
          result = ResourceBuilder.new(self, response, {}, {})
          result.run
        end
      end

      def activate
        request = Request.new("/#{space.id}/content_types/#{id}/published", {}, nil, sys[:version])
        response = request.put
        result = ResourceBuilder.new(self, response, {}, {}).run
        if result.is_a? self.class
          refresh_data(result)
        else
          result
        end
      end

      def deactivate
        request = Request.new("/#{space.id}/content_types/#{id}/published")
        response = request.delete
        result = ResourceBuilder.new(self, response, {}, {}).run
        if result.is_a? self.class
          refresh_data(result)
        else
          result
        end
      end

      def active?
        !sys[:publishedAt].nil?
      end

      def self.create(space_id, attributes)
        fields = (attributes[:fields] || []).map(&:update_properties)
        request = Request.new("/#{space_id}/content_types/#{attributes[:id] || ''}", {name: attributes.fetch(:name),
                                                                                      description: attributes[:description],
                                                                                      fields: fields})
        response = attributes[:id].nil? ? request.post : request.put
        result = ResourceBuilder.new(self, response, {}, {})
        result.run
      end

      def update(attributes)
        parameters = {}
        parameters.merge!(name: (attributes[:name] || name))
        parameters.merge!(description: (attributes[:description] || description))
        parameters.merge!(fields: (attributes[:fields] || fields).map(&:update_properties))
        request = Request.new("/#{space.id}/content_types/#{id}", parameters, nil, sys[:version])
        response = request.put
        result = ResourceBuilder.new(self, response, {}, {}).run
        if result.is_a? self.class
          refresh_data(result)
        else
          result
        end
      end

      def save
        if id.nil?
          new_instance = self.class.create(space.id, @properties)
          refresh_data(new_instance)
        else
          update(@properties)
        end
      end

      alias_method :orig_fields, :fields

      def fields
        fields = orig_fields

        fields.instance_exec(self) do |content_type|

          fields.define_singleton_method(:add) do |field|
            content_type.update(fields: content_type.fields + [field])
          end

          fields.define_singleton_method(:create) do |params|
            field = Contentful::Management::Field.new
            field.id = params.fetch(:id)
            field.name = params.fetch(:name)
            field.type = params.fetch(:type)
            content_type.update(fields: content_type.fields + [field])
          end

        end

        fields
      end

    end
  end
end