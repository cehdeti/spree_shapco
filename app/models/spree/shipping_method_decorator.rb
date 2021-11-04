Spree::ShippingMethod.class_eval do
  scope :with_shapco, -> { joins(:shipping_categories).merge(Spree::ShippingCategory.with_shapco) }
end
