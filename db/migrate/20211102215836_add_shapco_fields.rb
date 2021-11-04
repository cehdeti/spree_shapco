class AddShapcoFields < ActiveRecord::Migration[4.2]
  def change
    add_column :spree_shipping_categories, :shapco, :boolean, null: false, default: false
    add_column :spree_shipments, :sent_to_shapco, :boolean, null: false, default: false
  end
end
