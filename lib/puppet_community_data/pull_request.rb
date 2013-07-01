require 'sinatra/activerecord'
require 'active_record/base'

class PullRequest < ActiveRecord::Base
  ##
  # Return a new instance given data from the Github API.
  #
  # @param [Hash] pr_data the pull request data from the Github API used to
  #   construct our model of the pull request
  #
  # @return [PullRequest]
  def self.from_github(pr_data)
  end
end
