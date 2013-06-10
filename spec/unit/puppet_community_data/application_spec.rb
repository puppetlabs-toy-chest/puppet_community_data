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

    describe '#closed_pull_requests' do
      context "Repository puppetlabs/puppetlabs-stdlib" do
        let(:repo) { "puppetlabs/puppetlabs-stdlib" }

        subject { described_class.new([]).closed_pull_requests(repo) }
        subject do
          s = described_class.new([])
          s.github_api.stub(:pull_requests).with(repo, 'closed').and_return(closed_puppet_pull_requests)
          s.closed_pull_requests(repo)
        end

        it 'returns a hash of closed pull requests' do
          expect(subject).to be_a_kind_of Hash
        end

        it 'has integer keys for the pull request numbers' do
          expect(subject.keys[0]).to be_a_kind_of Integer
        end

        describe "values" do
          it 'has values which are arrays' do
            expect(subject.values[0]).to be_a_kind_of Array
          end

          it 'has two element arrays for values' do
            expect(subject.values[0].length).to eq(2)
          end

          it 'has arrays for values which have an integer for the first element' do
            expect(subject.values[0][0]).to be_a_kind_of Integer
          end

          it 'has arrays for values which have true or false for the second element' do
            expect([TrueClass, FalseClass].any? {|bool| subject.values[0][1].class == bool}).to be_true
          end
        end

        it 'includes pull request 123' do
          expect(subject.keys).to include(123)
        end
      end
    end

    describe '#pull_request_lifetimes' do
      let(:pull_requests) {{10 => [30, true], 11 => [5, false], 12 => [100, true]}}
      subject { described_class.new([]).pull_request_lifetimes(pull_requests)}

      it 'returns liftimes as an array of integers' do
        expect(subject).to eq([30,5,100])
      end
    end

    describe '#calculate averages' do
      let(:lifetimes) {[15,30,5,20,10]}
      subject {described_class.new([]).calculate_averages(lifetimes)}

      it 'returns the correct shortest lifetime' do
        expect(subject["shortest"]).to eq(5)
      end

      it 'returns the correct longest lifetime' do
        expect(subject["longest"]).to eq(30)
      end

      it 'returns the correct average lifetime' do
        expect(subject["average"]).to eq(16)
      end

      it 'returns the correct median' do
        expect(subject["median"]).to eq(15)
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
          subject.should_receive(:csv_write).with(filename, example1)

          subject.write_to_csv(filename, example1)
        end
      end

      context 'when an Array is given' do
        it 'writes a CSV array to the filename'do
          subject.should_receive(:csv_write).with(filename, example2)

          subject.write_to_csv(filename, example2)
        end
      end
    end
  end
end
