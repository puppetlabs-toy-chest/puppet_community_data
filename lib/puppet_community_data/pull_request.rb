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
    where(:pull_request_number => pr_data["pr_number"],
          :repository_name => pr_data["repo_name"],
          :repository_owner => pr_data["repo_owner"],
          :merged_status => pr_data["merge_status"],
          :time_closed => pr_data["time_closed"],
          :time_opened => pr_data["time_opened"]).first_or_create
  end
end
