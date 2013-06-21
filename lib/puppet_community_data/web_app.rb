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

    hiera_pull_requests.each do |pull_request_num, pull_request|
      if pull_request.new_record?
        pull_request.save
      end
    end

    facter_pull_requests.each do |pull_request_num, pull_request|
      if pull_request.new_record?
        pull_request.save
      end
    end

    get '/' do
      "Hello world! From #{self.class.inspect}"
    end
  end
end
