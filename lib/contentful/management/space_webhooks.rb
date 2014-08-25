module Contentful
  module Management
    class SpaceWebhooks

      attr_reader :space

      def initialize(space)
        @space = space
      end

      def all(params = {})
        Webhook.all(space.id, params)
      end

      def find(webhook_id)
        Webhook.find(space.id, webhook_id)
      end

    end
  end
end