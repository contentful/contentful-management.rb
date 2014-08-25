module Contentful
  module Management
    class SpaceAssets

      attr_reader :space

      def initialize(space)
        @space = space
      end

      def all(params = {})
        Asset.all(space.id, params)
      end

      def find(asset_id)
        Asset.find(space.id, asset_id)
      end

      def create(attributes)
        Asset.create(space.id, attributes)
      end

      def new
        asset = Asset.new
        asset.sys[:space] = space
        asset
      end

    end
  end
end