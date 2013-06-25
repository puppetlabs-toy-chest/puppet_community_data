require 'spec_helper'
require 'puppet_community_data/application'

describe PuppetCommunityData::Application do
  def github_oauth_token
    ENV['PCD_GITHUB_OAUTH_TOKEN'] || 'XXXXXXXXXXX'
  end

  CACHE = {}

  def closed_puppet_pull_requests
    CACHE[:closed_puppet_pull_requests] ||= read_request_fixture
  end

  def read_request_fixture
    fpath = File.join(SPECDIR, 'fixtures', 'closed_pull_requests.json')
    JSON.parse(File.read(fpath))
  end

  subject do
    described_class.new([])
  end

  describe "arguments" do
    let(:argv) do ['--github-oauth-token', '1234token']
    end

    subject do
      PuppetCommunityData::Application.new(argv)
    end

    describe '#opts' do
      it 'is an empty hash before runnning' do
        expect(subject.opts).to eq({})
      end

      it 'sets the :github_oauth_token after running' do
        subject.parse_options!
        expect(subject.opts[:github_oauth_token]).to eq '1234token'
      end
    end

    describe 'command line options' do
      it "accepts command line options" do
        subject.parse_options!
      end

      describe 'github_oauth_token' do
        it "returns the string account identifier" do
          subject.parse_options!
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

    describe '#pull_request_lifetimes' do
      let(:pull_requests) {{10 => [30, true, 'puppetlabs/puppet'], 11 => [5, false, 'puppetlabs/puppet']}}
      subject {described_class.new([]).pull_request_lifetimes(pull_requests)}

      it 'returns liftimes as an array of integers' do
        expect(subject).to eq([30,5])
      end
    end

    describe '#generate repositories' do
      let(:names) {['puppetlabs/puppet', 'puppetlabs/facter', 'puppetlabs/hiera']}
      subject{described_class.new([])}

      it "generates the correct number of repositories" do
        subject.generate_repositories(names)
        expect(subject.repositories.length).to eq(3)
      end

      it "generates the correct repository objects" do
        subject.generate_repositories(names)
        expect(subject.repositories[0].full_name).to eq('puppetlabs/puppet')
      end
    end

    describe '#write_pull_requests_to_database' do
      let(:repo) {PuppetCommunityData::Repository.new('puppetlabs/facter')}
      subject{described_class.new([])}

      it "collects the closed pull requests for that repostiory" do
        pending
      end

      it "writes the collected pull requests" do
        pending
      end
    end

    describe '#write_to_json', :focus => true do
      let(:filename) {"/tmp/output.json"}
      let(:example1) {{'somekey' => 'somevalue'}}
      let(:example2) {[1,2,3,4]}
      subject {described_class.new([])}

      context 'when a Hash is given' do
        it 'writes a JSON hash to the filename' do
          subject.should_receive(:write).with(filename, JSON.pretty_generate(example1))

          subject.write_to_json(filename, example1)
        end
      end

      context 'when an Array is given' do
        it 'writes a JSON array to the filename' do
          subject.should_receive(:write).with(filename, JSON.pretty_generate(example2))

          subject.write_to_json(filename, example2)
        end
      end
    end

    describe '#write_to_csv', :focus => true do
      let(:filename) {"/temp/output.csv"}
      let(:example1) {{'somekey' => 'somevalue'}}
      let(:example2) {[1,2,3,4]}
      subject {described_class.new([])}

      context 'when a Hash is given' do
        it 'writes a CSV hash to the filename' do
          subject.should_receive(:csv_hash_write).with(filename, example1)

          subject.write_to_csv(filename, example1)
        end
      end

      context 'when an Array is given' do
        it 'writes a CSV array to the filename'do
          subject.should_receive(:csv_array_write).with(filename, example2)

          subject.write_to_csv(filename, example2)
        end
      end
    end
  end
end
