module Contentful
  module Management
    # Utility methods used by the contentful management gem
    module Support
      class << self
        # Transforms CamelCase into snake_case (taken from zucker)
        def snakify(object)
          snake = String(object).gsub(/(?<!^)[A-Z]/) { "_#{$&}" }
          snake.downcase
        end

        # Merges two hashes with recursion
        def deep_hash_merge(query_hash, attribute_hash)
          query_hash.merge(attribute_hash) do |_key, oldval, newval|
            oldval = oldval.to_hash if oldval.respond_to?(:to_hash)
            newval = newval.to_hash if newval.respond_to?(:to_hash)
            oldval.class.to_s == 'Hash' && newval.class.to_s == 'Hash' ? deep_hash_merge(oldval, newval) : newval
          end
        end

        # If the query contains the :select operator, we enforce :sys properties.
        # The SDK requires sys.type to function properly, but as other of our SDKs
        # require more parts of the :sys properties, we decided that every SDK should
        # include the complete :sys block to provide consistency accross our SDKs.
        def normalize_select!(parameters)
          return parameters unless parameters.key?(:select)

          parameters[:select] = parameters[:select].split(',').map(&:strip) if parameters[:select].is_a? String
          parameters[:select] = parameters[:select].reject { |p| p.start_with?('sys.') }
          parameters[:select] << 'sys' unless parameters[:select].include?('sys')
          parameters[:select] = parameters[:select].join(',')

          parameters
        end

        # Returns the path for a specified resource name.
        def base_path_for(resource_name)
          {
            'Role' => 'roles',
            'Space' => 'spaces',
            'Asset' => 'assets',
            'Entry' => 'entries',
            'Locale' => 'locales',
            'Upload' => 'uploads',
            'ApiKey' => 'api_keys',
            'UIExtension' => 'extensions',
            'Environment' => 'environments',
            'ContentType' => 'content_types',
            'PreviewApiKey' => 'preview_api_keys',
            'SpaceMembership' => 'space_memberships'
          }[resource_name]
        end
      end
    end
  end
end
