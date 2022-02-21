class MoveShapcoToOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :spree_orders, :sent_to_shapco, :boolean, null: false, default: false

    reversible do |dir|
      dir.up do
        order_ids = Spree::Shipment.distinct(:order_id).where(sent_to_shapco: true).pluck(:order_id)
        Spree::Order.where(id: order_ids).update_all(sent_to_shapco: true)
      end

      dir.down do
        order_ids = Spree::Order.where(sent_to_shapco: true).pluck(:id)
        Spree::Shipment.where(order_id: order_ids).update_all(sent_to_shapco: true)
      end
    end

    remove_column :spree_shipments, :sent_to_shapco, :boolean, null: false, default: false
  end
end
