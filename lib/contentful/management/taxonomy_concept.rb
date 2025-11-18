# frozen_string_literal: true

require_relative 'resource'
require_relative 'resource/system_properties'
require_relative 'resource/refresher'

module Contentful
  module Management
    # Resource class for TaxonomyConcept.
    # https://www.contentful.com/developers/docs/references/content-management-api/#/reference/taxonomy/concept
    class TaxonomyConcept
      include Contentful::Management::Resource
      include Contentful::Management::Resource::SystemProperties
      include Contentful::Management::Resource::Refresher

      property :uri, :string
      property :prefLabel, :hash
      property :altLabels, :hash
      property :hiddenLabels, :hash
      property :notations, :array
      property :note, :hash
      property :changeNote, :hash
      property :definition, :hash
      property :editorialNote, :hash
      property :example, :hash
      property :historyNote, :hash
      property :scopeNote, :hash
      property :broader, :array
      property :related, :array
      property :conceptSchemes, :array

      # Finds a Taxonomy Concept by ID.
      #
      # @param [Contentful::Management::Client] client
      # @param [String] organization_id
      # @param [String] concept_id
      #
      # @return [Contentful::Management::TaxonomyConcept]
      def self.find(client, organization_id, concept_id)
        requester = ResourceRequester.new(client, self)
        requester.find(
          id: concept_id,
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
          { 'X-contentful-version' => sys[:version].to_s }
        )
      end

      def ancestors(query = {})
        requester = ResourceRequester.new(client, self.class)
        endpoint_options = {
          organization_id: sys[:organization].id,
          id: id,
          ancestors: true
        }
        requester.all(endpoint_options, query)
      end

      def descendants(query = {})
        requester = ResourceRequester.new(client, self.class)
        endpoint_options = {
          organization_id: sys[:organization].id,
          id: id,
          descendants: true
        }
        requester.all(endpoint_options, query)
      end

      # @private
      def self.build_endpoint(endpoint_options = {})
        organization_id = endpoint_options[:organization_id]
        base_url = "organizations/#{organization_id}/taxonomy/concepts"

        return "#{base_url}/total" if endpoint_options[:total]

        if endpoint_options.key?(:id)
          concept_url = "#{base_url}/#{endpoint_options[:id]}"
          return "#{concept_url}/ancestors" if endpoint_options[:ancestors]
          return "#{concept_url}/descendants" if endpoint_options[:descendants]

          concept_url
        else
          base_url
        end
      end
    end
  end
end
