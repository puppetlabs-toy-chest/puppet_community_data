require 'sinatra'
require 'sinatra/activerecord'

require 'puppet_community_data/pull_request'

module PuppetCommunityData
  class WebApp < Sinatra::Base

    # Extend Sinatra with ActiveRecord database connections.
    register Sinatra::ActiveRecordExtension

    pull_request = PullRequest.create(:pull_request_number => 1, :repository_name => "hiera", :repository_owner => "puppetlabs", :lifetime_minutes => 25, :merged_status => true)

    get '/' do
      "Hello world! From #{self.class.inspect}"
    end
  end
end
