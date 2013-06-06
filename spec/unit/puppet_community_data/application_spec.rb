require 'spec_helper'
require 'puppet_community_data/application'

describe PuppetCommunityData::Application do
  def github_oauth_token
    ENV['PCD_GITHUB_OAUTH_TOKEN'] || 'XXXXXXXXXXX'
  end

  CACHE = {}

  def closed_puppet_pull_requests
    fpath = File.join(SPECDIR, 'fixtures', 'closed_pull_requests.json')
    CACHE[:closed_puppet_pull_requests] ||= JSON.parse(File.read(fpath))
  end

  subject do
    described_class.new([])
  end

  it "runs" do
    subject.run
  end

  describe "arguments" do
    let(:argv) do
      ['--google-account', 'changethis@acme.com',
       '--google-password', 'mypassword',
       '--spreadsheet-key', '1234key',
       '--github-oauth-token', '1234token']
    end

    subject do
      PuppetCommunityData::Application.new(argv)
    end

    describe '#opts' do
      it 'is an empty hash before runnning' do
        expect(subject.opts).to eq({})
      end
      it 'sets the :google_account key after running' do
        subject.run
        expect(subject.opts[:google_account]).to eq 'changethis@acme.com'
      end
      it 'sets the :google_password key after running' do
        subject.run
        expect(subject.opts[:google_password]).to eq 'mypassword'
      end
      it 'sets the :spreadsheet_key after running' do
        subject.run
        expect(subject.opts[:spreadsheet_key]).to eq '1234key'
      end
      it 'sets the :github_oauth_token after running' do
        subject.run
        expect(subject.opts[:github_oauth_token]).to eq '1234token'
      end
    end

    describe 'command line options' do
      describe '#google_account' do
        it "accepts --google-account" do
          subject.run
        end
        it "returns the string account identifier" do
          subject.run
          expect(subject.google_account).to eq("changethis@acme.com")
        end
      end

      describe '#google_password' do
        it "accepts --google-password" do
          subject.run
        end
        it "returns the string password identifier" do
          subject.run
          expect(subject.google_password).to eq("mypassword")
        end
      end

      describe '#spreadsheet_key' do
        it "accepts --spreadsheet-key" do
          subject.run
        end
        it "returns the string account identifier" do
          subject.run
          expect(subject.spreadsheet_key).to eq("1234key")
        end
      end

      describe 'github_oauth_token' do
        it "accepts --github-oauth-token" do
          subject.run
        end
        it "returns the string account identifier" do
          subject.run
          expect(subject.github_oauth_token).to eq("1234token")
        end
      end
    end

    describe '#github_api' do
      it 'is a Octokit::Client instance' do
        expect(subject.github_api).to be_a_kind_of Octokit::Client
      end
      it 'sets auto_traversal to true to get paginated results' do
        expect(subject.github_api.auto_traversal).to eq(true)
      end
    end

    describe '#closed_pull_requests', :focus => true do
      context "Repository puppetlabs/puppetlabs-stdlib" do
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
