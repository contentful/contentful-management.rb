# frozen_string_literal: true

require_relative 'space_association_methods_factory'

module Contentful
  module Management
    # Wrapper for User API for usage from within Space
    # @private
    class SpaceUserMethodsFactory
      attr_reader :space

      def initialize(space)
        @space = space
      end

      def find(id)
        User.find(space.client, space.id, nil, id)
      end

      def all(params = {})
        User.all(space.client, space.id, nil, params, nil)
      end
    end
  end
end
