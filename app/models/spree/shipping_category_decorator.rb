Spree::ShippingCategory.class_eval do
  scope :with_shapco, -> { where(shapco: true) }
end
