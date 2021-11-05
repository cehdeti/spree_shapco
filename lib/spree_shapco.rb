require 'spree_core'
require 'spree_shapco/engine'
require 'shapco'

module SpreeShapco
  class << self
    def client
      Shapco.new(
        Spree::Config.shapco_url_slug,
        Spree::Config.shapco_username,
        Spree::Config.shapco_password,
        Spree::Config.shapco_subscriber_id
      )
    end
  end
end
