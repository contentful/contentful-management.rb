# frozen_string_literal: true

require_relative 'resource'
require_relative 'resource/system_properties'
require_relative 'resource/refresher'

module Contentful
  module Management
    # Resource class for TaxonomyConceptScheme.
    # https://www.contentful.com/developers/docs/references/content-management-api/#/reference/taxonomy/concept-scheme
    class TaxonomyConceptScheme
      include Contentful::Management::Resource
      include Contentful::Management::Resource::SystemProperties
      include Contentful::Management::Resource::Refresher

      property :uri, :string
      property :prefLabel, :hash
      property :definition, :hash
      property :topConcepts, :array
      property :concepts, :array
      property :totalConcepts, :integer

      # Finds a Taxonomy Concept Scheme by ID.
      #
      # @param [Contentful::Management::Client] client
      # @param [String] organization_id
      # @param [String] concept_scheme_id
      #
      # @return [Contentful::Management::TaxonomyConceptScheme]
      def self.find(client, organization_id, concept_scheme_id)
        requester = ResourceRequester.new(client, self)
        requester.find(
          id: concept_scheme_id,
          organization_id: organization_id
        )
      end

      def self.all(client, organization_id, query = {})
        requester = ResourceRequester.new(client, self)
        requester.all({ organization_id: organization_id }, query)
      end

      def self.total(client, organization_id)
        response = client.get(
          Request.new(
            client,
            build_endpoint(total: true, organization_id: organization_id)
          )
        )
        response.object['total']
      end

      def self.create(client, organization_id, attributes)
        requester = ResourceRequester.new(client, self)
        requester.create(
          {
            organization_id: organization_id,
            id: attributes[:id]
          }.compact,
          attributes
        )
      end

      # @private
      def self.create_attributes(_client, attributes)
        attributes
      end

      def update(patch_operations)
        requester = ResourceRequester.new(client, self.class)
        requester.patch(
          {
            organization_id: sys[:organization].id,
            id: id
          },
          patch_operations,
          {
            'Content-Type' => 'application/json-patch+json',
            'X-Contentful-Version' => sys[:version].to_s
          }
        )
      end

      def destroy
        requester = ResourceRequester.new(client, self.class)
        requester.destroy(
          {
            organization_id: sys[:organization].id,
            id: id
          },
          {},
          { 'X-Contentful-Version' => sys[:version].to_s }
        )
      end

      # @private
      def self.build_endpoint(endpoint_options = {})
        organization_id = endpoint_options[:organization_id]
        base_url = "organizations/#{organization_id}/taxonomy/concept-schemes"

        return "#{base_url}/total" if endpoint_options[:total]

        if endpoint_options.key?(:id)
          "#{base_url}/#{endpoint_options[:id]}"
        else
          base_url
        end
      end
    end
  end
end
