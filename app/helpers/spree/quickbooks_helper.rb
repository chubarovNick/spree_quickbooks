module Spree
  module QuickbooksHelper
    def quickbooks_integrated?
      SpreeQuickbooks::Config[:quickbooks_realm]
    end
  end
end