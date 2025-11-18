require 'spec_helper'
require 'contentful/management/taxonomy_concept_scheme'
require 'contentful/management/client'

module Contentful
  module Management
    describe TaxonomyConceptScheme do
      let(:token) { ENV.fetch('CF_TEST_CMA_TOKEN', '<ACCESS_TOKEN>') }

      let(:organization_id) { '4kQeJmhUWIKtNNmMkketza' }
      let(:concept_scheme_id) { '2hNivoHTKM4MbTM4519T5E' }
      let(:client) { Client.new(token, raise_errors: true) }

      subject { client.taxonomy_concept_schemes(organization_id) }

      describe '.find' do
        it 'returns a Contentful::Management::TaxonomyConceptScheme' do
          vcr('taxonomy_concept_scheme/find') do
            concept_scheme = subject.find(concept_scheme_id)
            expect(concept_scheme).to be_a Contentful::Management::TaxonomyConceptScheme
            expect(concept_scheme.id).to eq concept_scheme_id
            expect(concept_scheme.pref_label['en-US']).to eq 'Home Products'
          end
        end
      end

      describe '.all' do
        it 'returns an array of taxonomy concept schemes' do
          vcr('taxonomy_concept_scheme/all') do
            schemes = subject.all
            expect(schemes).to be_a(Contentful::Management::Array)
            expect(schemes.first).to be_a(Contentful::Management::TaxonomyConceptScheme)
          end
        end
      end

      describe '.total' do
        it 'returns the total number of concept schemes' do
          vcr('taxonomy_concept_scheme/total') do
            total = subject.total
            expect(total).to be_a(Integer)
          end
        end
      end

      describe '.create' do
        it 'creates a taxonomy concept scheme' do
          vcr('taxonomy_concept_scheme/create') do
            scheme = subject.create(
              prefLabel: { 'en-US' => 'New Scheme' }
            )
            expect(scheme).to be_a(Contentful::Management::TaxonomyConceptScheme)
            expect(scheme.pref_label['en-US']).to eq('New Scheme')
          end
        end
      end

      describe '#update' do
        it 'updates a taxonomy concept scheme' do
          vcr('taxonomy_concept_scheme/update') do
            scheme = subject.find(concept_scheme_id)
            updated_scheme = scheme.update([
                                             { op: 'add', path: '/prefLabel/en-US', value: 'New Scheme Name' }
                                           ])
            expect(updated_scheme).to be_a(Contentful::Management::TaxonomyConceptScheme)
            expect(updated_scheme.pref_label['en-US']).to eq('New Scheme Name')
          end
        end
      end

      describe '#destroy' do
        it 'deletes a taxonomy concept scheme' do
          vcr('taxonomy_concept_scheme/destroy') do
            scheme = subject.find(concept_scheme_id)
            result = scheme.destroy
            expect(result).to be_truthy
          end
        end
      end
    end
  end
end



