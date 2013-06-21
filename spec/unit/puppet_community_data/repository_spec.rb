require 'spec_helper'
require 'puppet_community_data/repository'

describe PuppetCommunityData::Repository do
  it "returns the repository owner" do
    repository = PuppetCommunityData::Repository.new("theowner/therepo")

    expect(repository.owner).to eq("theowner")
  end

  it "returns the repository name" do
    repository = PuppetCommunityData::Repository.new("theowner/therepo")

    expect(repository.name).to eq("therepo")
  end

  it "returns the full repository name" do
    repository = PuppetCommunityData::Repository.new("theowner/therepo")

    expect(repository.full_name).to eq("theowner/therepo")
  end
end
