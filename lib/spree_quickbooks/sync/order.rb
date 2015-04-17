module SpreeQuickbooks
  module Sync
    class Order
      attr_reader :order

      def initialize(order)
        @order = order
      end

      def perform
        service = sales_receipt_service
        if sales_receipt = service.find_by_order_number
          sales_receipt_service.update sales_receipt
        else
          service.create
        end
      end
      
      
      private

      def prepare_json
        hash = order.as_json
        hash[:line_items] = order.line_items.map{|line_item| line_item.as_json.merge({sku: line_item.variant.sku}) }
        hash[:adjustmentss] = order.adjustments.as_json
        hash[:payments] =  order.payments.valid.map {|payment| payment.as_json.merge({payment_method: payment.payment_method.name}) }
        hash[:shipping_address] = order.ship_address.as_json
        hash[:billing_address] = order.bill_address.as_json
        hash[:totals] = {order: order.total }
        {order: hash}.with_indifferent_access
      end

      def sales_receipt_service
        payload = prepare_json
        SpreeQuickbooks::Services::SalesReceipt.new(payload)
      end
    end
  end
end