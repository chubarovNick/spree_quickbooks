module Spree
  class QuickbooksConfiguration < Preferences::Configuration
    preference :quickbooks_key, :string
    preference :quickbooks_secret, :string
    preference :quickbooks_access_token, :string
    preference :quickbooks_access_secret, :string
    preference :quickbooks_realm, :string
    preference :quickbooks_poll_stock_timestamp, :string
    preference :quickbooks_web_orders_user, :string
    preference :quickbooks_payment_method_name, :string
    preference :quickbooks_account_name, :string
    preference :quickbooks_deposit_to_account_name, :string
  end
end