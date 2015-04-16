module SpreeQuickbooks
  module Services
    class PaymentMethod < Base
      attr_reader :order

      def initialize( payload)
        super('PaymentMethod')

        @order = payload[:order]
      end

      def augury_name
        if order.has_key?('credit_cards') && !order['credit_cards'].empty?
          order['credit_cards'].first['cc_type']
        elsif order['payments'] && order['payments'].first.is_a?(Hash)
          order['payments'].first['payment_method']
        else
          'Check'
        end
      end

      def qb_name
        # NOTE due to bug which might send the mapping as a string. e.g.
        #
        #   "[{\"visa\":\"credit-card\",\"master-card\":\"credit-card\"}]"
        #
        payment_method_name_mapping = JSON.parse(SpreeQuickbooks::Config['quickbooks_payment_method_name'])

        lookup_value!(payment_method_name_mapping.first, augury_name)
      end

      def matching_payment
        quickbooks.fetch_by_name(qb_name) ||
            (raise Exception.new("No PaymentMethod '#{qb_name}' defined in Quickbooks"))
      end
    end
  end
end
