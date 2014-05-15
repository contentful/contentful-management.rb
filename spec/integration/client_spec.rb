## Defines the client api to the users

require 'spec_helper'

require 'contentful/management/client'

describe 'Client' do
  let(:client) { Contentful::Management::Client.new('such_a_long_token') }
  let(:space_id) { 'xxddi16swo35' }
  let(:space_version) { 1 }

  it 'gets all spaces for a user' do
    vcr(:get_spaces) { expect(client.spaces).to be_kind_of Contentful::Array }
  end

  it 'gets a specific space' do
    vcr(:get_space) { expect(client.space(space_id)).to be_kind_of Contentful::Space }
  end

  it 'delets a space' do
    vcr(:delete_space_success) do
      expect(client.delete_space(space_id)).to eq true
    end
  end

  it 'updates a space' do
    vcr(:update_space) do
      updated_space = client.update_space(space_id, 'NewName', space_version)
      expect(updated_space.sys[:version]).to eql space_version + 1
    end
  end
end
