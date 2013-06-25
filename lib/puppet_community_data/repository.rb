require 'puppet_community_data/pull_request'

require 'chronic'

module PuppetCommunityData
  class Repository
    attr_reader :owner, :name

    def initialize(repository)
      @owner, @name = repository.split('/')
    end

    def full_name
      [@owner, @name].join('/')
    end

    ##
    # closed_pull_requests
    #
    #
    def closed_pull_requests(github_api)
      closed_pull_requests = github_api.pull_requests(full_name, 'closed')

      closed_pull_requests.collect do |pr|
        was_merged = !!(pr['merged_at'])

        open_time = (Chronic.parse(pr['created_at'])).to_time
        close_time = (Chronic.parse(pr['closed_at'])).to_time
        pull_request_ttl = ((close_time - open_time)/60).to_i
        PullRequest.new(:pull_request_number => pr['number'],
                        :repository_name => name,
                        :repository_owner => owner,
                        :lifetime_minutes => pull_request_ttl,
                        :merged_status => was_merged)
      end
    end
  end
end
