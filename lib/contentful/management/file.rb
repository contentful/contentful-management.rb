require_relative '../resource'

module Contentful
  module Management
    class File
      include Contentful::Resource

      property :fileName, :string
      property :contentType, :string
      property :details
      property :url, :string
    end
  end
end
