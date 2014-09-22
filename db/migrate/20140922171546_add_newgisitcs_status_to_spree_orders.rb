class AddNewgisitcsStatusToSpreeOrders < ActiveRecord::Migration
  def change
    add_column :spree_orders, :newgistics_status, :string
  end
end
