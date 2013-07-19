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
      pr_dates = Array.new
      puppet_pulls.each do |pr|
        pr_dates.push(pr.time_closed)
      end
      pr_dates.to_json
    end
  end
end
