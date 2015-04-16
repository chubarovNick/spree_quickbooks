Spree::Order.class_eval do

  after_update do
    if self.state == 'complete'
      create_or_update_order
    end
  end

  private


  def create_or_update_order
    service = sales_receipt_service
    if sales_receipt = service.find_by_order_number
      sales_receipt_service.update sales_receipt
    else
      service.create
    end
  end

  def prepare_json
    hash = self.as_json
    hash[:line_items] = self.line_items.map{|line_item| line_item.as_json.merge({sku: line_item.variant.sku}) }
    hash[:adjustmentss] = self.adjustments.as_json
    hash[:payments] =  self.payments.valid.map {|payment| payment.as_json.merge({payment_method: payment.payment_method.name}) }
    hash[:shipping_address] = self.ship_address.as_json
    hash[:billing_address] = self.bill_address.as_json
    hash[:totals] = {order: self.total }
    {order: hash}.with_indifferent_access
  end

  def sales_receipt_service
    payload = prepare_json
    SpreeQuickbooks::Services::SalesReceipt.new(payload)
  end

end