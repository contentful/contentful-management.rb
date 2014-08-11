module Contentful
  module Management
    module Resource
      module AssetFields

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