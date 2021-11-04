class AddShapcoItemIdField < ActiveRecord::Migration[4.2]
  def change
    add_column :spree_variants, :shapco_item_id, :string, null: true
  end
end
