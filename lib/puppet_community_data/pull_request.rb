require 'sinatra/activerecord'
require 'active_record/base'

class PullRequest < ActiveRecord::Base
  def save_if_new
    save if new_record?
  end
end
