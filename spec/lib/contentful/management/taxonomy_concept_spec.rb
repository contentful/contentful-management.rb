require 'spec_helper'
require 'contentful/management/taxonomy_concept'
require 'contentful/management/client'

module Contentful
  module Management
    describe TaxonomyConcept do
      let(:token) { ENV.fetch('CF_TEST_CMA_TOKEN', '<ACCESS_TOKEN>') }

      let(:organization_id) { '4kQeJmhUWIKtNNmMkketza' }
      let(:concept_id) { '5KHXWlmxvntrrB09szapUp' }
      let(:client) { Client.new(token) }

      subject { client.taxonomy_concepts(organization_id) }

      describe '.find' do
        it 'returns a Contentful::Management::TaxonomyConcept' do
          vcr('taxonomy_concept/find') do
            concept = subject.find(concept_id)
            expect(concept).to be_a Contentful::Management::TaxonomyConcept
            expect(concept.id).to eq concept_id
            expect(concept.pref_label['en-US']).to eq 'Sofas'
          end
        end
      end

      describe '.all' do
        it 'returns an array of taxonomy concepts' do
          vcr('taxonomy_concept/all') do
            concepts = subject.all
            expect(concepts).to be_a(Contentful::Management::Array)
            expect(concepts.first).to be_a(Contentful::Management::TaxonomyConcept)
          end
        end
      end

      describe '.total' do
        it 'returns the total number of concepts' do
          vcr('taxonomy_concept/total') do
            total = subject.total
            expect(total).to be_a(Integer)
          end
        end
      end

      describe '.create' do
        it 'creates a taxonomy concept' do
          vcr('taxonomy_concept/create') do
            concept = subject.create(
              prefLabel: { 'en-US' => 'Bicycles' }
            )
            expect(concept).to be_a(Contentful::Management::TaxonomyConcept)
            expect(concept.pref_label['en-US']).to eq('Bicycles')
          end
        end

        it 'creates a taxonomy concept with a user-defined id' do
          vcr('taxonomy_concept/create_with_id') do
            concept = subject.create(
              id: 'my-custom-id',
              prefLabel: { 'en-US' => 'Custom Bicycles' }
            )
            expect(concept).to be_a(Contentful::Management::TaxonomyConcept)
            expect(concept.id).to eq('my-custom-id')
            expect(concept.pref_label['en-US']).to eq('Custom Bicycles')
          end
        end
      end

      describe '#update' do
        it 'updates a taxonomy concept' do
          vcr('taxonomy_concept/update') do
            concept = subject.find(concept_id)
            updated_concept = concept.update([
                                               { op: 'add', path: '/prefLabel/en-US', value: 'New Label' }
                                             ])
            expect(updated_concept).to be_a(Contentful::Management::TaxonomyConcept)
            expect(updated_concept.pref_label['en-US']).to eq('New Label')
          end
        end
      end

      describe '#ancestors' do
        it 'returns an array of ancestor concepts' do
          vcr('taxonomy_concept/ancestors') do
            concept = subject.find('livingRoom')
            ancestors = concept.ancestors
            expect(ancestors).to be_a(Contentful::Management::Array)
            expect(ancestors.first).to be_a(Contentful::Management::TaxonomyConcept)
          end
        end
      end

      describe '#descendants' do
        it 'returns an array of descendant concepts' do
          vcr('taxonomy_concept/descendants') do
            concept = subject.find('greenSofas')
            descendants = concept.descendants
            expect(descendants).to be_a(Contentful::Management::Array)
            expect(descendants.first).to be_a(Contentful::Management::TaxonomyConcept)
          end
        end
      end

      describe '#destroy' do
        it 'deletes a taxonomy concept' do
          vcr('taxonomy_concept/destroy') do
            concept = subject.find(concept_id)
            result = concept.destroy
            expect(result).to be_truthy
          end
        end
      end
    end
  end
end
