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

    def google_account
      return @opts[:google_account]
    end

    def google_passowrd
      return @opts[:google_password]
    end

    def spreadsheet_key
      return @opts[:spreadsheet_key]
    end

    def github_oauth_token
      return @opts[:github_oauth_token]
    end

    def github_api
      @github_api ||= Octokit::Client.new(:auto_traversal => true, :oauth_token => github_oauth_token)
    end

    ##
    # closed_pull_requests extracts specific information from all of the pull
    # requests on Github.
    #
    # @param [String] repo The repository to obtain all pull requests from.
    #
    # @return [Hash] keyed by the pull request number with computed metrics.
    def closed_pull_requests(repo)
      closed_pull_requests = github_api.pull_requests(repo, 'closed')
      pull_requests_by_num = Hash.new

      closed_pull_requests.each do |pr|

        if (pr['merged_at'] != nil)
          was_merged =true
        end

        open_time = pr['created_at']
        open_time = (Chronic.parse(open_time)).to_time
        close_time = pr['closed_at']
        close_time = (Chronic.parse(close_time)).to_time
        pull_request_num = pr['number']
        pull_request_ttl = ((close_time - open_time)/60).to_i
        pull_requests_by_num[pull_request_num] = [pull_request_ttl,was_merged]
      end

      return pull_requests_by_num
    end

    #
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
  end
end
