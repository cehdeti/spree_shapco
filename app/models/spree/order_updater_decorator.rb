module ShapcoOrderUpdater
  def update_payment_state
    initial_state = order.payment_state
    super.tap { order.send_to_shapco if initial_state != 'paid' && order.payment_state == 'paid' }
  end
end

Spree::OrderUpdater.class_eval do
  prepend ShapcoOrderUpdater
end
