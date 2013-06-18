require 'sinatra'

module PuppetCommunityData
  class WebApp < Sinatra::Base
    get '/' do
      "Hello world! From #{self.class.inspect}"
    end
  end
end
