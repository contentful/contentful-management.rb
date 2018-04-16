require_relative 'resource'

module Contentful
  module Management
    # An Asset's file schema
    class File
      include Contentful::Management::Resource

      property :details
      property :url, :string
      property :fileName, :string
      property :contentType, :string
    end
  end
end
