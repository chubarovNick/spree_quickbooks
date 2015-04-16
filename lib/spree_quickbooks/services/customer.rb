module SpreeQuickbooks
  module Services
    class Customer < Base
      attr_reader :order

      def initialize(payload)
        super('Customer')
        @order = payload[:order]
      end

      def find_or_create
        name = use_web_orders? ? 'Web Orders' : nil
        fetch_by_display_name(name) || create
      end

      def fetch_by_display_name(name = nil)
        util = Quickbooks::Util::QueryBuilder.new
        clause = util.clause('DisplayName', '=', name || display_name)

        query = "SELECT * FROM Customer WHERE #{clause}"
        quickbooks.query(query).entries.first
      end

      def display_name
        "#{order['billing_address']['firstname']} #{order['billing_address']['lastname']}".strip
      end

      def create
        new_customer = create_model

        if use_web_orders?
          new_customer.display_name = 'Web Orders'
        else
          new_customer.given_name = order['billing_address']['firstname']
          new_customer.family_name = order['billing_address']['lastname']
          new_customer.display_name = display_name
          new_customer.email_address = order[:email]

          new_customer.billing_address = ::SpreeQuickbooks::Services::Address.build order['billing_address']
          new_customer.shipping_address = ::SpreeQuickbooks::Services::Address.build order['shipping_address']
        end

        quickbooks.create new_customer
      end

      private

      def use_web_orders?
        SpreeQuickbooks::Config['quickbooks_web_orders_user'] == 'true'
      end

    end
  end
end