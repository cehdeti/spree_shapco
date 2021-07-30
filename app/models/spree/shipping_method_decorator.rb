Spree::ShippingMethod.class_eval do
  scope :with_shapco, -> { joins(:shipping_categories).merge(Spree::ShippingCategory.with_shapco) }

  def as_shapco
  end

  private

  def carrier
    admin_name.split(' ').first
  end
end
