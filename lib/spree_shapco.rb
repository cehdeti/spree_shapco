require 'spree_core'
require 'spree_shapco/engine'

module SpreeShapco
  class << self
    def client
      @client ||= build_client
    end

    def reset!
      @client = nil
    end

    private

    def build_client
      Shapco.new(
        Spree::Config.shapco_url_slug,
        Spree::Config.shapco_username,
        Spree::Config.shapco_password,
        Spree::Config.shapco_subscriber_id
      )
    end
  end
end
