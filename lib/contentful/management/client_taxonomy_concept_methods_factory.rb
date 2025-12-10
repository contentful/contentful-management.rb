# frozen_string_literal: true

require_relative 'client_association_methods_factory'

module Contentful
  module Management
    # Wrapper for Taxonomy Concept API for usage from within Client
    # @private
    class ClientTaxonomyConceptMethodsFactory
      include Contentful::Management::ClientAssociationMethodsFactory

      def initialize(client, organization_id)
        super(client)
        @organization_id = organization_id
      end

      def find(resource_id)
        associated_class.find(client, @organization_id, resource_id)
      end

      def all(query = {})
        associated_class.all(client, @organization_id, query)
      end

      def create(attributes)
        associated_class.create(client, @organization_id, attributes)
      end

      def total
        associated_class.total(client, @organization_id)
      end
    end
  end
end
