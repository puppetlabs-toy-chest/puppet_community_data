require 'sinatra'

module PuppetCommunityData
  class WebApp < Sinatra::Base

    # Extend Sinatra with ActiveRecord database connections.
    register Sinatra::ActiveRecordExtension

    get '/' do
      "Hello world! From #{self.class.inspect}"
    end
  end
end
