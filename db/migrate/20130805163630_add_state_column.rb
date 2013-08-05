class AddStateColumn < ActiveRecord::Migration
  def up
    add_column :pull_requests, :closed, :boolean
  end

  def down
  end
end
