class AddShapcoTitleToVariants < ActiveRecord::Migration[5.2]
  def change
    add_column :spree_variants, :shapco_name, :string, null: true
  end
end
