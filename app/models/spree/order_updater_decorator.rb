module ShapcoOrderUpdater
  def update_payment_state
    initial_state = order.payment_state
    super.tap { create_shapco_order if initial_state != 'paid' && order.payment_state == 'paid' }
  end

  private

  def create_shapco_order
    order.shipments.send_to_shapco.each(&:send_to_shapco)
  end
end

Spree::OrderUpdater.class_eval do
  prepend ShapcoOrderUpdater
end
