Deface::Override.new(
  virtual_path:  "spree/admin/shared/sub_menu/_configuration",
  name: "add_shapco_admin_menu_link",
  insert_bottom: "[data-hook='admin_configurations_sidebar_menu']",
  text: "<%= configurations_sidebar_menu_item 'Shapco Settings', edit_admin_shapco_settings_path %>"
)
