require 'sinatra'
require 'sinatra/activerecord'
require 'json'

require 'puppet_community_data/pull_request'
require 'puppet_community_data/application'

module PuppetCommunityData
  class WebApp < Sinatra::Base

    set :root, File.expand_path('../../../', __FILE__)

    # Extend Sinatra with ActiveRecord database connections.
    register Sinatra::ActiveRecordExtension

    get '/' do
      erb :main
    end

    get '/data/puppet_pulls' do
      start_date = params[:start]
      end_date = params[:end]
      start_date ||= '2011-07-01'
      puppet_pulls = PullRequest.all(:conditions => ["time_closed > ?", Date.parse(start_date)])
      pull_requests = Array.new
      puppet_pulls.each do |pr|

        from_community = "Puppet Labs"
        from_community = "Community" if pr.from_community

        merged = "Closed"
        merged = "Merged" if pr.merged_status

        pull_requests.push(Hash["close_time" => pr.time_closed,
                                "repo_name" => pr.repository_name,
                                "ttl" => ((pr.time_closed - pr.time_opened)/86400).to_i,
                                "merged" => merged,
                                "community" => from_community])
      end

      pull_requests.to_json
    end
  end
end
