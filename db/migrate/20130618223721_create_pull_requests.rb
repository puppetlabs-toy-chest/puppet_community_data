class CreatePullRequests < ActiveRecord::Migration
  def up
    create_table :pull_requests do |t|
      t.integer :pull_request_number
      t.string :repository_name
      t.string :repository_owner
      t.boolean :merged_status
      t.date :time_opened
      t.date :time_closed
    end
  end

  def down
    drop_table :pull_requests
  end
end
