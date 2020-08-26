require_relative '../../lib/storyblok/request'
require 'spec_helper'

describe Storyblok::Request do
  subject { described_class.new(client, endpoint) }

  let(:client) { 'fake_client' }
  let(:endpoint) { 'some.url.com' }
  let(:query) { {my_key: 'my_value'} }
  let(:id) { 222 }

  context "#copy" do
    it "Returns a copy of StoryBlock:Request object initialized" do
      object_duplicated = subject.copy
      expect(subject.client).to        eq(object_duplicated.client)
      expect(subject.endpoint).to      eq(object_duplicated.endpoint)
      expect(subject.query).to         eq(object_duplicated.query)
      expect(subject.id).to            eq(object_duplicated.id)
      expect(subject.type).to          eq(object_duplicated.type)
      expect(subject.object_id).not_to eq(object_duplicated.object_id)
    end
  end
end
