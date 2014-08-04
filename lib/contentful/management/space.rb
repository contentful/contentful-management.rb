# -*- encoding: utf-8 -*-
require_relative 'resource'
require_relative 'locale'
require_relative 'content_type'
require_relative 'asset'
require_relative 'entry'

module Contentful
  module Management
    class Space
      include Contentful::Management::Resource
      include Contentful::Management::Resource::SystemProperties
      include Contentful::Management::Resource::Refresher

      property :name, :string
      property :organization, :string
      property :locales, Locale

      def self.all
        request = Request.new('')
        response = request.get
        result = ResourceBuilder.new(self, response, {}, {})
        spaces = result.run
        Contentful::Management::Client.shared_instance.update_dynamic_entry_cache_for_spaces!(spaces)
        spaces
      end

      def self.find(space_id)
        request = Request.new("/#{ space_id }")
        response = request.get
        result = ResourceBuilder.new(self, response, {}, {})
        space = result.run
        Contentful::Management::Client.shared_instance.update_dynamic_entry_cache_for_space!(space) if space.is_a?Space
        space
      end

      def self.create(attributes)
        request = Request.new('', { 'name' => attributes.fetch(:name) }, id = nil, organization_id: attributes[:organization_id])
        response = request.post
        result = ResourceBuilder.new(self, response, {}, {})
        result.run
      end

      def update(attributes)
        request = Request.new("/#{ id }", { 'name' => attributes.fetch(:name) }, id = nil,{ version: sys[:version], organization_id: attributes[:organization_id]})
        response = request.put
        result = ResourceBuilder.new(self, response, {}, {})
        refresh_data(result.run)
      end

      def save
        if id.nil?
          new_instance = self.class.create(name: name, organization_id: organization)
          refresh_data(new_instance)
        else
          update(name: name, organization_id: organization)
        end
      end

      def destroy
        request = Request.new("/#{ id }")
        response = request.delete
        if response.status == :no_content
          return true
        else
          ResourceBuilder.new(self, response, {}, {}).run
        end
      end

      def content_types
        content_types = ContentType.all(id)

        content_types.instance_exec(self) do |space|

          define_singleton_method(:all) do
            ContentType.all(space.id)
          end

          define_singleton_method(:create) do |params|
            ContentType.create(space.id, params)
          end

          define_singleton_method(:find) do |content_type_id|
            ContentType.find(space.id, content_type_id)
          end

          define_singleton_method(:new) do
            ct = ContentType.new
            ct.sys[:space] = space
            ct
          end

        end
        content_types
      end

      def locales
        locales = Locale.all(id)

        locales.instance_exec(self) do |space|
          define_singleton_method(:all) do
            Locale.all(space.id)
          end

          define_singleton_method(:create) do |params|
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
          define_singleton_method(:all) do
            Asset.all(space.id)
          end

          define_singleton_method(:find) do |asset_id|
            Asset.find(space.id, asset_id)
          end

          define_singleton_method(:create) do |params|
            Asset.create(space.id, params)
          end

          define_singleton_method(:new) do
            asset = Asset.new
            asset.sys[:space] = space
            asset
          end
        end
        assets
      end

      def entries
        entries = Entry.all(id)

        entries.instance_exec(self) do |space|
          define_singleton_method(:all) do
            Entry.all(space.id)
          end

          define_singleton_method(:find) do |entry_id|
            Entry.find(space.id, entry_id)
          end
        end
        entries
      end

    end
  end
end
