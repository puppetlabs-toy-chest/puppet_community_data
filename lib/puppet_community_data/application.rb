require 'puppet_community_data'
require 'puppet_community_data/version'
require 'puppet_community_data/repository'
require 'puppet_community_data/pull_request'

require 'octokit'
require 'json'
require 'csv'
require 'trollop'

module PuppetCommunityData
  class Application

    attr_reader :opts
    attr_accessor :repositories

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

    def setup_environment
      unless @environment_setup
        parse_options!
        @environment_setup = true
      end
    end

    ##
    # run the application.
    def run
      setup_environment
    end

    def version
      PuppetCommunityData::VERSION
    end

    def github_oauth_token
      return @opts[:github_oauth_token]
    end

    def github_api
      @github_api ||= Octokit::Client.new(:auto_traversal => true, :oauth_token => github_oauth_token)
    end

    ##
    # Given an array of repository names, genearte_repositories
    # will create a repository object for each one and add it to
    # the instance variable @repositories
    #
    # @param [Array] repo_names is an array of strings which
    # represent the names of the repositories to collect pull
    # requests from
    def generate_repositories(repo_names)
      @repositories ||= Array.new

      repo_names.each do |repo_name|
        repositories.push(Repository.new(repo_name))
      end
    end

    ##
    # Given an array of repository names as strings,
    # write_pull_requests_to_database will generate repositry objects
    # for each one. Then, it will get a collection of closed pull
    # requests from that repository, and if they are not already in
    # the database, it will add them.
    def write_pull_requests_to_database
      repositories.each do |repo|
        pull_requests = repo.closed_pull_requests(github_api)
        pull_requests.each do |pull_request|
          if pull_request.nil?
            warn "Encounter nil pull request, skipping database entry"
          else
            PullRequest.from_github(pull_request)
          end
        end
      end
    end

    ##
    # parse_options parses the command line arguments and sets the @opts
    # instance variable in the application instance.
    #
    # @return [Hash] options hash
    def parse_options!
      env = @env
      @opts = Trollop.options(@argv) do
        version "Puppet Community Data #{version} (c) 2013 Puppet Labs"
        banner "---"
        text "Gather data from source repositories and produce metrics."
        text ""
        opt :github_oauth_token, "The oauth token to create instange of GitHub API (PCD_GITHUB_OAUTH_TOKEN)",
          :default => (env['PCD_GITHUB_OAUTH_TOKEN'] || '1234changeme')
      end
    end

    ##
    # write_to_json takes a given input, converts it to json,
    # and writes it to the specified file path
    #
    # @param [String] file_name is the file the data will
    # be written to
    # @param [Array, Hash] to_write is the data to be written
    def write_to_json(file_name, to_write)
      write(file_name, JSON.pretty_generate(to_write))
    end

    ##
    # write_to_csv takes the given input, parses it
    # appropriately, and writes it to the specified file path
    #
    # @param [String] file_name is the file the data will be
    # written to
    # @param [Array, Hash] to_write is the data to be written
    def write_to_csv(file_name, to_write)
      if(to_write.kind_of?(Hash))
        csv_hash_write(file_name, to_write)
      else
        csv_array_write(file_name, to_write)
      end
    end

    ##
    # write is a private delegate method to make it easier to test File.open
    #
    # @api private
    def write(filename, data)
      File.open(filename, "w+") {|f| f.write(data) }
    end

    private :write

    ##
    # csv_array_write is a private delegate method to make it easier to test
    # CSV.open
    #
    # @api private
    def csv_array_write(filename, data)
      CSV.open(filename, "w+") do |csv|
        csv << ["LIFETIMES"]
        data.each do |value|
          to_write = [value]
          csv << to_write
        end
      end
    end

    private :csv_array_write

    ##
    # csv_hash_write is a private delegate method designed to handle hash input
    # and to make it easier to test CSV.open
    #
    # @api private
    def csv_hash_write(filename, data)
      CSV.open(filename, "w+") do |csv|
        csv << ["PR_NUM", "REPO", "LIFETIME" "MERGE_STATUS"]
        data.each do |key, value|
          row = [key, value[2], value[0], value[1]]
          csv << row
        end
      end
    end

    private :csv_hash_write
  end
end
