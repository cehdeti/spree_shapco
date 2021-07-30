Spree::Shipment.class_eval do
  SHAPCO_SUCCESS_RESPONSE = '1'.freeze

  scope :with_shapco, -> { joins(:shipping_methods).merge(Spree::ShippingMethod.with_shapco) }
  scope :sent_to_shapco, -> { where(sent_to_shapco: true) }
  scope :not_sent_to_shapco, -> { where(sent_to_shapco: false) }
  scope :send_to_shapco, -> { distinct.merge(with_shapco).merge(not_sent_to_shapco) }

  def logger
    rails_logger = Rails.logger
    model_logger = super
    model_logger.is_a?(rails_logger.class) ? model_logger : rails_logger
  end

  def as_shapco
    {
      product_details: {
        items: {
            item: manifest.map do |item|

              sku = item.line_item.variant.sku

              if item.part
                sku = item.variant.sku
              end

              {
                products_name: item.name,
                products_desc: item.description,
                products_sku: sku,
                products_price: item.line_item.price,
                products_quantity: item.quantity
              }
            end
          }
      }
    }
  end

  def send_to_shapco
    return if sent_to_shapco
    logger.debug("Shapco Order ##{order.number} Shipment ##{number}")
    logger.info 'Creating shipment record'
    success = Rails.env.production? ? do_send_to_shapco : simulate_send_to_shapco
    update_column :sent_to_shapco, success
  end

  private

  def do_send_to_shapco
    serialized = as_shapco
    logger.info("Sending shipment: #{serialized}")
    response = SpreeShapco.client.create_order(serialized)
    (response.body[:int32] == SHAPCO_SUCCESS_RESPONSE).tap do |success|
      logger.error("Error creating shipment: #{response.body}") unless success
    end
  rescue => ex
    logger.error("Error creating shipment: #{ex.message}")
    false
  end

  def simulate_send_to_shapco
    logger.debug("Not in production environment, skipping shipment creation. Would have sent: #{as_shapco}")
    true
  end
end
