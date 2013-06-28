require 'sinatra'
require 'sinatra/activerecord'

require 'puppet_community_data/pull_request'
require 'puppet_community_data/application'

module PuppetCommunityData
  class WebApp < Sinatra::Base

    # Extend Sinatra with ActiveRecord database connections.
    register Sinatra::ActiveRecordExtension

    # FIXME This should not be at the class scope, it should be part of a
    # request method.
    # @application = Application.new
    # repo_names = ['puppetlabs/puppet', 'puppetlabs/facter', 'puppetlabs/puppetlabs-stdlib', 'puppetlabs/hiera']
    # @application.write_pull_requests_to_database(repo_names)

    get '/test' do
      pull_request = PullRequest.new
      pull_request.save_if_new
      "Pull Request in database: #{pull_request.inspect}"
    end

    get '/' do
      "Hello world! From #{self.class.inspect}"
    end
  end
end
