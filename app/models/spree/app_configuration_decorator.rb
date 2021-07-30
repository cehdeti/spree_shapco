Spree::AppConfiguration.class_eval do
  preference :shapco_url_prefix, :string
  preference :shapco_username, :string
  preference :shapco_password, :password
  preference :shapco_subscriber_id, :string
end
