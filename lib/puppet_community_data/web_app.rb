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

    get '/data/:repo/pull_request' do
      puppet_pulls = PullRequest.where(:repository_owner => params[:repo])
      puppet_pulls = puppet_pulls.sort_by &:time_closed
      puppet_pulls.to_json
      [ 5, 10, 13, 19, 21, 25, 22, 18, 15, 13,
        11, 12, 15, 20, 18, 17, 16, 18, 23, 25].to_json
    end
  end
end
