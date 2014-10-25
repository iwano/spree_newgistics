class AddSpreeNewgisticsLogs < ActiveRecord::Migration
  def change
    create_table :spree_newgistics_logs do |t|
      t.string :job_id
      t.timestamps
    end
  end
end
