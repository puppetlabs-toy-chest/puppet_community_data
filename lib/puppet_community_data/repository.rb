require 'puppet_community_data/pull_request'

require 'chronic'

module PuppetCommunityData
  class Repository
    attr_reader :owner, :name

    def initialize(repository)
      @owner, @name = repository.split('/')
    end

    ##
    # full_name returns the "full name" of the repository which is in the
    # format of "owner/name"
    #
    # @ return [String] the full name of the repository in the correct
    # format
    def full_name
      [@owner, @name].join('/')
    end

    ##
    # Given a Octokit object, closed_pull_requests will generate a collection
    # of pull request objects for all closed pull requests in a given
    # repository
    #
    # @param [Octokit] github_api is the instance of the GitHub API
    # needed to read from the repository
    #
    # @ return [Array] of pull request objects representing the pull requests
    # for the given repository
    def closed_pull_requests(github_api)
      closed_pull_requests = github_api.pull_requests(full_name, 'closed')

      closed_pull_requests.collect do |pr|
        was_merged = !!(pr['merged_at'])
        open_time = (Chronic.parse(pr['created_at'])).to_time
        close_time = (Chronic.parse(pr['closed_at'])).to_time
        # FIXME This should probably be moved out.
      end
    end
  end
end
