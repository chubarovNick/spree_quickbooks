Deface::Override.new(virtual_path: 'spree/admin/shared/_configuration_menu',
                     name: 'add_quickbooks_settings',
                     insert_bottom: "[data-hook='admin_configurations_sidebar_menu']",
                     text: '<%= configurations_sidebar_menu_item(:quickbooks_settings, admin_quickbooks_path) %>',
                     disabled: false)
