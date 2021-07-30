namespace :spree_shapco do
  desc 'Sends unsent orders to Shapco'
  task send_orders: :environment do
    Rails.logger.debug 'Shapco send orders: Starting send'

    shipments = Spree::Shipment.send_to_shapco.ready
    total = shipments.count
    Rails.logger.debug "Shapco send orders: Sending #{total} order(s)"

    shipments.each do |shipment|
      begin
        shipment.send_to_shapco
      rescue => ex
        Rails.logger.error "Shapco send orders: Error sending: #{ex.message}, shipment ID: #{shipment.id}"
        false
      end
    end

    Rails.logger.debug "Shapco send orders: sent #{total} shipments"
  end
end
