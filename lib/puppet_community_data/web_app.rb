require 'sinatra'
require 'sinatra/activerecord'

require 'puppet_community_data/pull_request'
require 'puppet_community_data/application'

module PuppetCommunityData
  class WebApp < Sinatra::Base

    # Extend Sinatra with ActiveRecord database connections.
    register Sinatra::ActiveRecordExtension

    @application = Application.new

    hiera_pull_requests = @application.closed_pull_requests("puppetlabs/hiera")
    facter_pull_requests = @application.closed_pull_requests("puppetlabs/facter")

    hiera_pull_requests.each do |key, value|
      pull_request = PullRequest.create(:pull_request_number => key,
                                        :repository_name => value[2],
                                        :repository_owner => value[3],
                                        :lifetime_minutes => value[0],
                                        :merged_status => value[1])
     end

    facter_pull_requests.each do |key, value|
      pull_request = PullRequest.create(:pull_request_number => key,
                                        :repository_name => value[2],
                                        :repository_owner => value[3],
                                        :lifetime_minutes => value[0],
                                        :merged_status => value[1])
    end

    get '/' do
      "Hello world! From #{self.class.inspect}"
    end
  end
end
