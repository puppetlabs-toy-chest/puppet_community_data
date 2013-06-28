require 'sinatra/activerecord'
require 'active_record/base'

class PullRequest < ActiveRecord::Base

  ##
  # save_if_new checks to see if the given pull requests
  # is a new entry to the database, and if not, it writes it
  def save_if_new
    if !(PullRequest.exists?(:pull_request_number => pull_request_number,
                 :repository_name => repository_name,
                 :repository_owner => repository_owner))
      save
    end
  end
end
