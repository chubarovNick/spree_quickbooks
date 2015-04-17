Spree::Order.class_eval do

  after_update do
    if self.state == 'complete'
      create_or_update_order
    end
  end

  private


  def create_or_update_order
   SpreeQuickbooks::Sync::Order.new(self).perform
  end

end