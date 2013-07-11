require 'sinatra'
require 'sinatra/activerecord'

require 'puppet_community_data/pull_request'
require 'puppet_community_data/application'

module PuppetCommunityData
  class WebApp < Sinatra::Base

    # Extend Sinatra with ActiveRecord database connections.
    register Sinatra::ActiveRecordExtension

    get '/test' do
      "Wrote to database!"
    end

    get '/overview' do
      @facter_pulls = PullRequest.find_by_sql("select * from pull_requests where repository_name='facter'")
      erb :overview
    end

    get '/' do
      "Hello world! From #{self.class.inspect}"
    end
  end
end
