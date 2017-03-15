require_relative 'entry_association_methods_factory'

module Contentful
  module Management
    # Wrapper for Snapshot API for usage from within Space
    # @private
    class EntrySnapshotMethodsFactory
      include Contentful::Management::EntryAssociationMethodsFactory

      def new
        fail 'Not supported'
      end

      def create(*)
        fail 'Not supported'
      end

      def update(*)
        fail 'Not supported'
      end
    end
  end
end
