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

    def get_pull_requests(repo, pr_status)
      pull_requests = @github_api.pullrequests(repo, pr_status)
      return pull_request
    end

    def old_app
      # Collect recently closed pull requests and print out some
      # relevent data about them
      puppet_pulls = @github_api.pull_requests('puppetlabs/puppet', 'closed')
      tp puppet_pulls, "title", "number", "created_at", "closed_at", "merged_at"

      # Use these to keep track of some info we will want later
      pull_requests = Hash.new
      num_merged = 0
      total_pull_requests = 0

      # Go through each pull request, calculate it's lifetime,
      # then store it in a new has with it's number as a key
      # and it's lifetime (in minutes) as a value
      puppet_pulls.each do |key, value|
        if(key['merged_at'] != nil)
          num_merged = num_merged +1
          was_merged = true
        end

        total_pull_requests = total_pull_requests + 1
        open_time = key['created_at']
        open_time = (Chronic.parse(open_time)).to_time
        close_time = key['closed_at']
        close_time = (Chronic.parse(close_time)).to_time
        pull_request_num = key['number']
        pull_request_ttl = ((close_time - open_time)/60).to_i
        pull_requests[pull_request_num] = [pull_request_ttl,was_merged]
      end

      # Create an array to keep track of all the pull request
      # lifetimes
      pull_request_lifetimes = Array.new

      puts "\n|Here is a list of recently closed pull requests in puppet:|\n"

      pull_requests.each do |key, value|
        puts "The pull request number is: #{key} And it's lifetime is: #{value} minutes"
        pull_request_lifetimes.push(value[0])
      end

      # Calculate some info about pull request lifetimes
      # and then print it out
      shortest = pull_request_lifetimes.min
      longest = pull_request_lifetimes.max
      total = pull_request_lifetimes.inject(:+)
      len = pull_request_lifetimes.length
      average = (total.to_f / len).to_i
      sorted = pull_request_lifetimes.sort
      median = len % 2 == 1 ? sorted[len/2] : (sorted[len/2 - 1] + sorted[len/2]).to_i / 2
      percent_merged = ((num_merged.to_f / total_pull_requests.to_f) * 100).to_i

      puts "\n|Here is some neat data about the lifetime of recently closed pull requests:|\n"
      puts "The shortest pull request lifetime was #{shortest} minutes"
      puts "The longest pull request lifetime was #{longest} minutes"
      puts "The average pull request lifetime was #{average} minutes"
      puts "The median pull request lifetime was #{median} minutes"
      puts "At least #{percent_merged}% of the pull requests were merged"

      # Write the hash of pull requests and their lifetimes to a json file
      json_file_path = File.absolute_path('/Users/haileekenney/Projects/puppet_community_data/data/lifetimes.json')

      File.open(json_file_path, 'w') do |file|
        file.puts(JSON.generate(pull_requests))
      end

      # Write the array of pull request lifetimes to a csv file
      csv_file_path = '/Users/haileekenney/Projects/puppet_community_data/data/lifetimes.csv'

      CSV.open(csv_file_path, 'w') do |csv|
        csv << pull_request_lifetimes
      end

      # Get ready to write to a Google spreadsheet
      google_session = GoogleDrive.login(gmail_email, gmail_password)
      spread_sheet = google_session.spreadsheet_by_key("0AviIC1XqtRxcdFJFRkdXX3BTano3MnhmemRCV3c1WkE").worksheets[0]
      puts "\nWriting data to Google spreadsheet, please wait..."
      col = 2

      # Write the pull request number and it's lifetime to a Good spreadsheet
      pull_requests.each do |key, value|
        spread_sheet[col, 1] = key
        spread_sheet[col, 2] = value[0]
        if(value[1])
          spread_sheet[col, 3] = "Merged"
        else
          spread_sheet[col, 3] = "Closed"
        end

        col = col + 1
      end

      # Save changes to spreadsheet
      spread_sheet.save()
    end
  end
end
