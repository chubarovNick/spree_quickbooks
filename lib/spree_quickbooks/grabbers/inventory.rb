module SpreeQuickbooks
  module Grabbers
    class Inventory
      attr_reader :item_service

      def initialize
        @item_service = SpreeQuickbooks::Services::Item.new
      end

      def perform
        Spree::Variant.all.find_each do |variant|
          @item = item_service.find_by_sku(variant.sku, 'Name, QtyOnHand')
          stock_adjustment = @item.quantity_on_hand.to_i - variant.total_on_hand
          stock_location = Spree::StockLocation.first
          stock_movement = stock_location.stock_movements.build({quantity: stock_adjustment})
          stock_movement.stock_item = stock_location.set_up_stock_item(variant)
          stock_movement.save!
        end
      end
    end
  end
end