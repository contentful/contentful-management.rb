module Contentful
  module Management
    module Resource
      # Adds Field Coercions for [Asset]
      module AssetFields
        # Special fields for Asset.
        def fields_coercions
          {
            title: :hash,
            description: :hash,
            file: Contentful::Management::File
          }
        end
      end
    end
  end
end
