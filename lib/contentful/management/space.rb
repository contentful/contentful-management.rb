require_relative '../resource'
require_relative 'locale'
require_relative 'content_type'

module Contentful
  module Management
    class Space

      include Contentful::Resource
      include Contentful::Resource::SystemProperties
      include Contentful::Resource::Refresher

      property :name, :string
      property :organization, :string
      property :locales, Locale

      def self.all
        request = Request.new('')
        response = request.get
        result = ResourceBuilder.new(self, response, {}, {})
        result.run
      end

      def self.find(space_id)
        request = Request.new("/#{space_id}")
        response = request.get
        result = ResourceBuilder.new(self, response, {}, {})
        result.run
      end

      def self.create(attributes)
        request = Request.new('', {'name' => attributes.fetch(:name)}, nil, nil, attributes[:organization_id])
        response = request.post
        result = ResourceBuilder.new(self, response, {}, {})
        result.run
      end

      def update(attributes)
        request = Request.new("/#{id}", {'name' => attributes.fetch(:name)}, nil, sys[:version])
        response = request.put
        result = ResourceBuilder.new(self, response, {}, {})
        refresh_data(result.run)
      end

      def save
        if id.nil?
          self.class.create(name: name)
        else
          update(name: name)
        end
      end

      def destroy
        request = Request.new("/#{id}")
        response = request.delete
        if response.status == :no_content
          return true
        else
          result = ResourceBuilder.new(self, response, {}, {})
          result.run
        end
      end

      def content_types
        content_types = ContentType.all(id)

        content_types.instance_exec(self) do |space|

          content_types.define_singleton_method(:create) do |params|
            ContentType.create(params.merge(space_id: space.id))
          end

          self.define_singleton_method(:find) do |conent_type_id|
            ContentType.find(space.id, conent_type_id)
          end

        end

        content_types
      end

      def locales
        locales = Locale.all(id)
        locales.define_singleton_method(:create) do |params|
          Locale.create(params)
        end
        locales
      end

    end

  end
end
