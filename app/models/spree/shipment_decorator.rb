Spree::Shipment.class_eval do

  scope :with_shapco, -> { joins(:shipping_methods).merge(Spree::ShippingMethod.with_shapco).distinct }
  scope :sent_to_shapco, -> { where(sent_to_shapco: true) }
  scope :not_sent_to_shapco, -> { where(sent_to_shapco: false) }
  scope :send_to_shapco, -> { distinct.merge(with_shapco).merge(not_sent_to_shapco) }

  def send_to_shapco
    return if sent_to_shapco
    logger.debug("Shapco Order ##{order.number} Shipment ##{number}")
    logger.info 'Creating shipment record'
    success = Rails.env.production? ? do_send_to_shapco : simulate_send_to_shapco
    update_column :sent_to_shapco, success
  end

  def as_shapco
    shapco_address = address.as_shapco

    {
      orders_id: order.id,
      order_number: order.number,
      shipping_mode: address.country.iso == 'CA' ? 'CanStd' : 'Ground',
      payment_method_name: 'Pay On Account',
      orders_due_date: order.created_at,
      total_weight: manifest.sum do |item|
        (item.part ? item.variant : item.line_item.variant).weight * item.quantity
      end,
      customer_details: shapco_address.transform_keys { |k| "customers_#{k}" }.merge(
        customers_email_address: order.email,
        customers_ID: Spree::Config.shapco_customer_id,
      ),
      shipping_details: shapco_address.transform_keys { |k| "delivery_#{k}" }.merge(
        delivery_email: order.email,
        delivery_street_address: "#{shapco_address[:street_address1]}, #{shapco_address[:street_address2]}",
        delivery_suburb: shapco_address[:city],
        shipping_extrafield: 'this cannot be blank',
        shipping_id: id,
      ),
      product_details: {
        items: manifest
          .select do |item|
            variant = item.part ? item.variant : item.line_item.variant
            variant.shapco_item_id?
          end
          .map do |item|
            variant = item.part ? item.variant : item.line_item.variant

            {
              orders_products_id: variant.id.to_s,
              products_name: variant.name,
              products_desc: variant.name,
              products_sku: "#{Spree::Config.shapco_customer_id}-#{variant.shapco_item_id}",
              item_client_id: variant.sku,
              products_quantity: item.quantity,
              products_price: variant.price.to_s,
            }
          end
      }
    }
  end

  def logger
    rails_logger = Rails.logger
    model_logger = super
    model_logger.is_a?(rails_logger.class) ? model_logger : rails_logger
  end

  private

  def do_send_to_shapco
    serialized = as_shapco
    logger.info("Sending shipment: #{serialized}")
    response = SpreeShapco.client.create_order(serialized)
    response['result'].tap do |success|
      logger.error("Error creating shipment: #{response}") unless success
    end
  end

  def simulate_send_to_shapco
    logger.debug("Not in production environment, skipping shipment creation. Would have sent: #{as_shapco}")
    true
  end
end
