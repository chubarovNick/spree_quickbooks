module SpreeQuickbooks
  module Sync
    class Products
      attr_reader :item_service

      def initialize
        @item_service = SpreeQuickbooks::Services::Item.new
      end

      def perform
        Spree::Variant.includes(:product).all.find_each do |variant|
          item_service.find_or_create_by_sku(variant_to_item(variant))
        end
      end

      private

      def variant_to_item(varaint)
        {
            sku: varaint.sku,
            description: varaint.product.description
        }

      end
    end
  end
end