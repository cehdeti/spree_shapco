class AddShapcoToShippingCategories < ActiveRecord::Migration
  def change
    add_column :spree_shipping_categories, :shapco, :boolean, null: false, default: false
  end
end
