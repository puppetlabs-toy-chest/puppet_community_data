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
    key_attributes = {
      :repository_owner    => pr_data["repo_owner"],
      :repository_name     => pr_data["repo_name"],
      :pull_request_number => pr_data["pr_number"],
    }

    model = self.where(key_attributes).first_or_create do |pr|
      pr.merged_status = pr_data["merge_status"]
      pr.time_closed = pr_data["time_closed"]
      pr.time_opened = pr_data["time_opened"]
    end
    model
  end
end
