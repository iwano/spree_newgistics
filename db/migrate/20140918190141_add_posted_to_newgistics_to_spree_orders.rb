class AddPostedToNewgisticsToSpreeOrders < ActiveRecord::Migration
  def change
    add_column :spree_orders, :posted_to_newgistics, :boolean, default: false
  end
end
