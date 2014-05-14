require 'spec_helper'
require_relative '../../lib/contentful/request'

# test the monkeypach for the request class
module Contentful
  describe Request do
    context 'monkey patch' do
      # let(:client) { Contentful::Management::Client.new('token') }
      let(:client) { double(Client) }
      let(:endpoint) { '/' }
      let(:request) { Request.new(client, endpoint) }
      subject { request }

      describe 'POST' do
        it { should respond_to(:post) }

        it 'calls post on the client' do
          expect(client).to receive(:post)

          request.post
        end
      end

      describe 'PUT' do
        it { should respond_to(:put) }

        it 'calls put on the client' do
          expect(client).to receive(:put)

          request.put
        end
      end

      describe 'DELETE' do
        it { should respond_to(:delete) }
        it 'calls delete on the client' do
          expect(client).to receive(:delete)

          request.delete
        end
      end
    end
  end
end
