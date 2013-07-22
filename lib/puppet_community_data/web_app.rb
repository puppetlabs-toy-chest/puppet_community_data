require 'sinatra'
require 'sinatra/activerecord'
require 'json'

require 'puppet_community_data/pull_request'
require 'puppet_community_data/application'

module PuppetCommunityData
  class WebApp < Sinatra::Base

    # Extend Sinatra with ActiveRecord database connections.
    register Sinatra::ActiveRecordExtension

    get '/overview' do
      erb :overview
    end

    get '/' do
      erb :main
    end

    get '/data/puppet_pulls' do
      puppet_pulls = PullRequest.where(:repository_owner => 'puppetlabs')
      pull_requests = Array.new
      puppet_pulls.each do |pr|
        pull_requests.push(Hash["close_time" => pr.time_closed,
                                "repo_name" => pr.repository_name])
      end
      pull_requests.to_json
    end
  end
end
