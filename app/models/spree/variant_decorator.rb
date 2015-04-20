Spree::Variant.class_eval do

  before_save do
    if changes[:sku] && changes[:sku].any?
      update_variant
    end
  end

  private

  def update_variant
    SpreeQuickbooks::Sync::Variant.new(changes[:sku]).perform
  end

end
