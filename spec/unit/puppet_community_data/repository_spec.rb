require 'spec_helper'
require 'puppet_community_data/repository'

describe PuppetCommunityData::Repository do

  CACHE = {}

  def closed_puppet_pull_requests
    CACHE[:closed_puppet_pull_requests] ||= read_request_fixture
  end

  def read_request_fixture
    fpath = File.join(SPECDIR, 'fixtures', 'closed_pull_requests.json')
    JSON.parse(File.read(fpath))
  end

  subject do
    described_class.new('puppetlabs/stdlib')
  end

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

  describe '#closed_pull_requests' do
    context "Repository puppetlabs/puppetlabs-stdlib" do
      let(:full_name) { "puppetlabs/puppetlabs-stdlib" }
      let(:repo) { PuppetCommunityData::Repository.new(full_name) }
      let(:github) { PuppetCommunityData::Application.new([]).github_api }

      subject do
        s = repo
        github.stub(:pull_requests).with(full_name, 'closed').and_return(closed_puppet_pull_requests)
        s.closed_pull_requests(github)
      end

      it 'returns an array of pull requests' do
        expect(subject).to be_a_kind_of Array
      end

      it 'the pull requests are represnted as Hashes of data' do
        expect(subject[0]).to be_a_kind_of Hash
      end
    end
  end
end
