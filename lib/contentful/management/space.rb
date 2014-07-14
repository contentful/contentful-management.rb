require_relative '../resource'
require_relative 'locale'
require_relative 'content_type'
require_relative 'asset'

module Contentful
  module Management
    class Space
      include Contentful::Resource
      include Contentful::Resource::SystemProperties
      include Contentful::Resource::Refresher

      property :name, :string
      property :organization, :string
      property :locales, Locale
      property :assets, Asset


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
        request = Request.new("/#{ id }", {'name' => attributes.fetch(:name)}, nil, sys[:version])
        response = request.put
        result = ResourceBuilder.new(self, response, {}, {})
        refresh_data(result.run)
      end

      def save
        if id.nil?
          new_instance = self.class.create(name: name)
          refresh_data(new_instance)
        else
          update(name: name)
        end
      end

      def destroy
        request = Request.new("/#{ id }")
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

          content_types.define_singleton_method(:all) do
            ContentType.all(space.id)
          end

          content_types.define_singleton_method(:create) do |params|
            ContentType.create(space.id, params)
          end

          define_singleton_method(:find) do |content_type_id|
            ContentType.find(space.id, content_type_id)
          end

        end

        content_types
      end

      def locales
        locales = Locale.all(id)

        locales.instance_exec(self) do |space|
          locales.define_singleton_method(:all) do
            Locale.all(space.id)
          end

          locales.define_singleton_method(:create) do |params|
            Locale.create(space.id, params)
          end

          define_singleton_method(:find) do |locale_id|
            Locale.find(space.id, locale_id)
          end
        end

        locales
      end

      def assets
        assets = Asset.all(id)

        assets.instance_exec(self) do |space|
          assets.define_singleton_method(:all) do
            Asset.all(space.id)
          end

          define_singleton_method(:find) do |asset_id|
            Asset.find(space.id, asset_id)
          end
        end
        assets
      end
    end
  end
end
