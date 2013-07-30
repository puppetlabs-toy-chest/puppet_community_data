class AddCommunityColumn < ActiveRecord::Migration
  def up
    add_column :pull_requests, :from_community, :boolean
  end

  def down
  end
end
