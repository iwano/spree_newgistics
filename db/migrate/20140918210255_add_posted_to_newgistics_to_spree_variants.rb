class AddPostedToNewgisticsToSpreeVariants < ActiveRecord::Migration
  def change
    add_column :spree_variants, :posted_to_newgistics, :boolean, default: false
  end
end
