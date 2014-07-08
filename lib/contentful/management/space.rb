require_relative '../resource'
require_relative '../locale'
require_relative '../request'

module Contentful
  module Management
      class Space

        include Contentful::Resource
        include Contentful::Resource::SystemProperties

        property :name, :string
        property :organization, :string
        property :locales, Locale

        def self.all
          request = Request.new('')
          response = request.get
          result = ResourceBuilder.new(self, response, {'Space' => Space}, {})
          result.run
        end

        def self.find(space_id)
          request = Request.new("/#{space_id}")
          response = request.get
          result = ResourceBuilder.new(self, response, {'Space' => Space}, {})
          result.run
        end

        def self.create
          headers = create_space_header(name)
          request = Request.new('', headers)
          response = request.post
          result = ResourceBuilder.new(self, response, {}, {})
          result.run
        end

        def update

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

      end

  end
end
