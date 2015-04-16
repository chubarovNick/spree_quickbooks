module SpreeQuickbooks
  class Services::SalesReceipt < Services::Base
    attr_reader :order, :payload
    attr_reader :payment_method_service, :line_service, :account_service, :customer_service

    def initialize(payload, options = {dependencies: true})
      super('SalesReceipt')
      @order = payload[:order]
      if options[:dependencies]
        @payment_method_service = ::SpreeQuickbooks::Services::PaymentMethod.new payload
        @customer_service = ::SpreeQuickbooks::Services::Customer.new payload
        @account_service = ::SpreeQuickbooks::Services::Account.new
        @line_service = ::SpreeQuickbooks::Services::Line.new payload
      end
    end

    def find_by_order_number
      query = "SELECT * FROM SalesReceipt WHERE DocNumber = '#{order_number}'"
      quickbooks.query(query).entries.first
    end

    def create
      sales_receipt = create_model
      build sales_receipt
      quickbooks.create sales_receipt
    end

    def update(sales_receipt)
      build sales_receipt
      if order[:shipments] && !order[:shipments].empty?
        sales_receipt.tracking_num = shipments_tracking_number.join(', ')
        sales_receipt.ship_method_ref = order[:shipments].last[:shipping_method]
        sales_receipt.ship_date = order[:shipments].last[:shipped_at]
      end
      quickbooks.update sales_receipt
    end

    private
    def order_number
      order[:number] || order[:id]
    end

    def build(sales_receipt)
      sales_receipt.doc_number = order_number
      sales_receipt.email = order['email']
      sales_receipt.total = order['totals']['order']

      sales_receipt.placed_on = order['placed_on']

      sales_receipt.ship_address = ::SpreeQuickbooks::Services::Address.build order['shipping_address']
      sales_receipt.bill_address = ::SpreeQuickbooks::Services::Address.build order['billing_address']

      sales_receipt.payment_method_id = payment_method_service.matching_payment.id
      sales_receipt.customer_id = customer_service.find_or_create.id

      # Associated as both DepositAccountRef and IncomeAccountRef
      #
      # Quickbooks might return an weird error if the name here is already used
      # by other, I think, quick_books account
      income_account = account_service.find_by_name SpreeQuickbooks::Config['quickbooks_account_name']

      sales_receipt.line_items = line_service.build_lines income_account

      # Default to Undeposit Funds account if no account is set
      #
      # Watch out for errors like:
      #
      #   A business validation error has occurred while processing your
      #   request: Business Validation Error: You need to select a different
      #   type of account for this transaction.
      #
      if SpreeQuickbooks::Config['quickbooks_deposit_to_account_name'].present?
        deposit_account = account_service.find_by_name SpreeQuickbooks::Config['quickbooks_deposit_to_account_name']
        sales_receipt.deposit_to_account_id = deposit_account.id
      end
    end

    def shipments_tracking_number
      order[:shipments].map do |shipment|
        shipment[:tracking]
      end
    end
  end
end