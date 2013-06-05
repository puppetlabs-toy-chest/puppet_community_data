require 'puppet_community_data'
require 'puppet_community_data/version'
require 'octokit'
require 'table_print'
require 'chronic'
require 'json'
require 'csv'
require 'google_drive'
require 'trollop'

module PuppetCommunityData
  class Application
    attr_reader :google_account
    attr_reader :google_password
    attr_reader :github_oauth_token
    attr_reader :spreadsheet_key
    attr_reader :opts

    ##
    # Initialize a new application instance.  See the run method to run the
    # application.
    #
    # @param [Array] argv The argument vector to use for options parsing.
    #
    # @param [Hash] env The environment hash to use for options parsing.
    def initialize(argv=ARGV, env=ENV.to_hash)
      @argv = argv
      @env  = env
      @opts = {}
    end

    ##
    # run the application.
    def run
      parse_options!
    end

    def version
      PuppetCommunityData::VERSION
    end

    ##
    # parse_options parses the command line arguments and sets the @opts
    # instance variable in the application instance.
    #
    # @api private
    #
    # @return [Hash] options hash
    def parse_options!
      env = @env

      @opts = Trollop.options(@argv) do
        version "Puppet Community Data #{version} (c) 2013 Puppet Labs"
        banner "---"
        text "Gather data from source repositories and produce metrics."
        text ""
        opt :google_account, "The google account to write results to (PCD_GOOGLE_ACCOUNT)",
          :default => (env['PCD_GOOGLE_ACCOUNT'] || 'changeme@puppetlabs.com')
        opt :google_password, "The password to the specified google count (PCD_GOOGLE_PASSWORD)",
          :default => (env['PCD_GOOGLE_PASSWORD'] || 'changeme')
        opt :spreadsheet_key, "The key for the desired google spreadsheet to write to (PCD_SPREADSHEET_KEY)",
          :default => (env['PCD_SPREADSHEET_KEY'] || '1234changeme')
        opt :github_oauth_token, "The oauth token to create instange of GitHub API (PCD_GITHUB_OAUTH_TOKEN)",
          :default => (env['PCD_GITHUB_OAUTH_TOKEN'] || '1234changeme')
      end
    end

    def github_api
      @github_api ||= Octokit::Client.new(:auto_tranversal => true, :oauth_token => github_oauth_token)
    end

    def google_session
      @google_session ||= GoogleDrive.login(gmail_user, gmail_password)
    end

    def google_spreadsheet
      @google_spreadsheet ||= @google_session.spreadsheet_by_key(spreadsheet_key).worksheet[0]
    end

    def get_pull_requests(repo, pr_status)
      pull_requests = @github_api.pullrequests(repo, pr_status)
      return pull_request
    end

    def sort_pulls_by_lifetime(pull_requests)
      @pull_requests_by_num = Hash.new

      pull_requests.each do |key, value|

        if (key[merged_at] != nil)
          was_merged =true
        end

        open_time = key['created_at']
        open_time = (Chronic.parse(open_time)).to_time
        close_time = key['closed_at']
        close_time = (Chronic.parse(close_time)).to_time
        pull_request_num = key['number']
        pull_request_ttl = ((close_time - open_time)/60).to_i
        @pull_request_by_num[pull_request_num] = [pull_request_ttl,was_merged]
      end
    end

    def get_pull_request_lifetimes(pull_requests)
      pull_request_lifetimes = Array.new

      @pull_requests_by_num.each do |key, value|
        pull_request_lifetimes.push(value[0])
      end

      return pull_request_lifetimes
    end

    def calculate_averages(pull_request_lifetimes)
      pull_request_data = Hash.new

      shortest = pull_request_lifetimes.min
      pull_request_data["shortest"] = shortest
      longest = pull_request_lifetimes.max
      pull_request_data["longest"] = longest
      total = pull_request_lifetimes.inject(:+)
      len = pull_request_lifetimes.length
      average = (total.to_f / len).to_i
      pull_request_data["average"] = average
      sorted = pull_request_lifetimes.sort
      median = len % 2 == 1 ? sorted[len/2] : (sorted[len/2 - 1] + sorted[len/2]).to_i / 2
      pull_request_data["median"] = median
      percent_merged = ((num_merged.to_f / total_pull_requests.to_f) * 100).to_i
      pull_request_data["percent_merged"] = percent_merged

      return pull_request_data
    end

    def write_to_json(json_file_path, to_write)
      File.open(json_file_path, 'w') do |file|
        file.puts(JSON.generate(to_write))
      end
    end

    def write_to_csv(csv_file_path, to_write)
      CSV.open(csv_file_path, 'w') do |csv|
        csv << to_write
      end
    end

    def write_pull_requests_to_spreadsheet(pull_requests)
      col = 2

      @pull_requets_by_num.each do |key, value|
        @google_spreadsheet[col, 1] = key
        @google_spreadsheet[col, 2] = value[0]
        if(value[1])
          @google_spreadsheet[col, 3] = "Merged"
        else
          @google_spreadsheet[col, 3] = "Closed"
        end

        col = col + 1
      end

      @google_spreadsheet.save()
    end
  end
end
