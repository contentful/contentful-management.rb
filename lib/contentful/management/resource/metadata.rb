# frozen_string_literal: true

module Contentful
  module Management
    module Resource
      # Adds metadata logic for [Resource] classes
      module Metadata
        # Returns the metadata hash
        attr_reader :_metadata

        # @private
        def initialize(object = nil, *)
          super
          @_metadata = {}
          extract_metadata_from_object! object if object
        end

        # @private
        def inspect(info = nil)
          if _metadata.empty?
            super(info)
          else
            super("#{info} @_metadata=#{_metadata.inspect}")
          end
        end

        private

        def extract_metadata_from_object!(object)
          return unless object.key?('metadata')

          object['metadata'].each do |key, value|
            @_metadata[key.to_sym] = case key
                                     when 'tags'
                                       coerce_tags(value)
                                     when 'concepts'
                                       coerce_concepts(value)
                                     else
                                       value
                                     end
          end
        end

        def coerce_tags(tags)
          tags.map { |tag| Contentful::Management::Link.new(tag) }
        end

        def coerce_concepts(concepts)
          concepts.map { |concept| Contentful::Management::Link.new(concept) }
        end
      end
    end
  end
end
