Spree::Variant.class_eval do

  before_save do
    if changes[:sku].any?
      service = SpreeQuickbooks::Services::Item.new
      sku_was, new_sku = changes[:sku]
      item = service.find_by_sku(sku_was)
      service.update(item, {name: new_sku})
    end
  end

end