class AddSentToShapcoToShipments < ActiveRecord::Migration
  def change
    add_column :spree_shipments, :sent_to_shapco, :boolean, null: false, default: false
  end
end
