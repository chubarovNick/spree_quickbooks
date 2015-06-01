module SpreeQuickbooks
  module Sync
    class Variant
      attr_reader :variant_changes

      def initialize(variant_changes)
        @variant_changes = variant_changes
      end

      def perform
        service = SpreeQuickbooks::Services::Item.new
        sku_was, new_sku = variant_changes
        item = service.find_by_sku(sku_was)
        if item
          service.update(item, {name: new_sku})
        else
          account_service = SpreeQuickbooks::Services::Account.new
          account = account_service.find_by_name('Inventory Asset')
          service.find_or_create_by_sku({sku: new_sku}, account)
        end
      end

    end
  end
end