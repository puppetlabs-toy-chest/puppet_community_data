require 'sinatra/activerecord'
require 'active_record/base'

class PullRequest < ActiveRecord::Base

  ##
  # save_if_new checks to see if the given pull requests
  # is a new entry to the database, and if not, it writes it
  def save_if_new
    save if new_record?
  end
end
