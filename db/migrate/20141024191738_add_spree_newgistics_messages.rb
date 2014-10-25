class AddSpreeNewgisticsMessages < ActiveRecord::Migration
  def change
    create_table :spree_newgistics_messages do |t|
      t.belongs_to :log
      t.string :details, null: false
      t.timestamps
    end
  end
end
