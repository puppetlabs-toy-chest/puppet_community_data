require 'spec_helper'
require 'puppet_community_data/repository'
require 'puppet_community_data/application'

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
        github.stub(:organization_member?).and_return(true)
        s.closed_pull_requests(github)
      end

      it 'returns an array of pull requests' do
        expect(subject).to be_a_kind_of Array
      end

      it 'the pull requests are represnted as Hashes of data' do
        expect(subject[0]).to be_a_kind_of Hash
      end

      it 'stores the correct pull request number' do
        expect(subject[0]["pr_number"]).to eq(159)
      end

      it 'stores the correct repository name' do
        expect(subject[0]["repo_name"]).to eq('puppetlabs-stdlib')
      end

      it 'stores the correct repository owner' do
        expect(subject[0]["repo_owner"]).to eq('puppetlabs')
      end

      it 'stores the correct merge status' do
        expect(subject[0]["merge_status"]).to eq(true)
      end

      it 'stores the correct open time' do
        expect(subject[0]["time_opened"]).to eq(Chronic.parse('2013-05-24T15:35:00Z').to_time)
      end

      it 'stores the correct open time' do
        expect(subject[0]["time_closed"]).to eq(Chronic.parse('2013-05-24T16:40:51Z').to_time)
      end

      it 'stores whether or not the pull request is from the community' do
        expect(subject[0]["from_community"]).to eq(false)
      end

      it 'stores the state of the pull request (open v closed)' do
        expect(subject[0]["closed_v_open"]).to eq(true)
      end
    end
  end
end
