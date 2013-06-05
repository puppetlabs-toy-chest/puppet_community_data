require 'spec_helper'
require 'puppet_community_data/application'

describe PuppetCommunityData::Application do
  def github_oauth_token
    ENV['PCD_GITHUB_OAUTH_TOKEN'] || 'XXXXXXXXXXX'
  end

  CACHE = {}

  def closed_puppet_pull_requests
    fpath = File.join(SPECDIR, 'fixtures', 'closed_pull_requests.puppet.json')
    CACHE[:closed_puppet_pull_requests] ||= JSON.parse(File.read(fpath))
  end

  subject do
    described_class.new([])
  end

  it "runs" do
    subject.run
  end

  describe "arguments" do
    subject do
      PuppetCommunityData::Application.new(['--google-account', 'changethis@acme.com'])
    end

    describe '#opts' do
      it 'is an empty hash before runnning' do
        expect(subject.opts).to eq({})
      end
      it 'sets the :google_account key after running' do
        subject.run
        expect(subject.opts[:google_account]).to eq 'changethis@acme.com'
      end
    end

    describe '#google_account' do
      it "accepts --google-account" do
        subject.run
      end
      it "returns the string account identifier" do
        subject.run
        expect(subject.google_account).to eq("changethis@acme.com")
      end
    end

    # Note, for full test coverage we could add more of the command line
    # options but they're not super important since they're pretty
    # straightforward.

    describe '#github_api' do
      it 'is a Octokit::Client instance' do
        expect(subject.github_api).to be_a_kind_of Octokit::Client
      end
      it 'sets auto_traversal to true to get paginated results' do
        expect(subject.github_api.auto_traversal).to eq(true)
      end
    end

    describe '#closed_pull_requests', :focus => true do
      context "Repository puppetlabs/puppet" do
        let(:repo) { "puppetlabs/puppet" }

        before :each do
          subject.github_api.stub(:pull_requests).with(repo, 'closed').and_return(closed_puppet_pull_requests)
        end

        it 'returns a hash of closed pull requests' do
          expect(subject.closed_pull_requests(repo)).to be_a_kind_of Hash
        end
        it 'includes pull request 123' do
          expect(subject.closed_pull_requests(repo).keys).to include(123)
        end
      end
    end
  end
end
