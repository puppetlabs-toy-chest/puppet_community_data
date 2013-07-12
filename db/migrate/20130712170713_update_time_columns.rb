class UpdateTimeColumns < ActiveRecord::Migration
  def up
    change_column :pull_requests, :time_opened, :datetime
    change_column :pull_requests, :time_closed, :datetime
  end

  def down
    change_column :pull_requests, :time_opened, :date
    change column :pull_requests, :time_closed, :date
  end
end
