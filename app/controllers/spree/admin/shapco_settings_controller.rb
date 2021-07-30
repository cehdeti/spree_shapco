module Spree
  module Admin
    class ShapcoSettingsController < Spree::Admin::BaseController
      CREDENTIAL_FIELDS = [
        :shapco_url_prefix,
        :shapco_username,
        :shapco_password,
        :shapco_subscriber_id
      ].freeze

      before_action :set_fields, :set_shipping_categories

      def edit
      end

      def update
        params.slice(*@fields).each do |name, value|
          Spree::Config[name] = value if Spree::Config.has_preference? name
        end

        @error = SpreeShapco.test

        if @error
          render :edit
        else
          flash[:success] = Spree.t(:successfully_updated, resource: Spree.t(:shapco_settings))
          redirect_to edit_admin_shapco_settings_path
        end
      end

      private

      def set_fields
        @credential_fields = CREDENTIAL_FIELDS
        @fields = @credential_fields.freeze
      end

      def set_shipping_categories
        @shipping_categories = Spree::ShippingCategory.with_shapco
      end
    end
  end
end
