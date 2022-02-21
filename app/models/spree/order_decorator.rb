Spree::Order.class_eval do

  def send_to_shapco
    return unless send_to_shapco?
    logger.debug("Shapco Order ##{number}")
    logger.info 'Creating shapco record'
    success = Rails.env.production? ? do_send_to_shapco : simulate_send_to_shapco
    update_column :sent_to_shapco, success
  end

  def send_to_shapco?
    !sent_to_shapco && !shapco_manifest.empty?
  end

  def as_shapco
    manifest = shapco_manifest

    {
      orders_id: id,
      order_number: number,
      shipping_mode: shipping_address.country.iso == 'CA' ? 'CanStd' : 'Ground',
      payment_method_name: 'Pay On Account',
      orders_due_date: created_at,
      total_weight: manifest.sum { |(variant, quantity)| variant.weight * quantity },
      customer_details: billing_address.as_shapco.transform_keys { |k| "customers_#{k}" }.merge(
        customers_email_address: email,
        customers_ID: Spree::Config.shapco_customer_id
      ),
      shipping_details: shipping_address.as_shapco.transform_keys { |k| "delivery_#{k}" }.merge(
        delivery_email: email,
        shipping_extrafield: 'this cannot be blank',
        shipping_id: id
      ),
      product_details: {
        items: manifest.each_pair.map do |variant, quantity|
          {
            orders_products_id: variant.id.to_s,
            products_name: variant.name,
            products_desc: variant.name,
            products_sku: "#{Spree::Config.shapco_customer_id}-#{variant.shapco_item_id}",
            item_client_id: variant.sku,
            products_quantity: quantity,
            products_price: variant.price.to_s
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

  def shapco_manifest
    line_items
      .each_with_object(Hash.new(0)) do |line_item, counter|
        # The `Spree::LineItem.quantity_by_variant` method comes from the
        # `spree_product_assembly` library and is used to recurse into product
        # bundles. If aren't using that library, this should be changed to use
        # another method to collect variants and their quantities.
        line_item.quantity_by_variant.each { |variant, quantity| counter[variant] += quantity }
      end
      .select { |variant, _| variant.shipping_category.shapco? }
  end

  def do_send_to_shapco
    serialized = as_shapco
    logger.info("Sending order to shapco: #{serialized}")
    response = SpreeShapco.client.create_order(serialized)
    response['result'].tap do |success|
      logger.error("Error creating order: #{response}") unless success
    end
  end

  def simulate_send_to_shapco
    logger.debug("Not in production environment, skipping order creation. Would have sent: #{as_shapco}")
    true
  end
end
