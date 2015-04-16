module SpreeQuickbooks
  module Services
    class Item < Base
      def initialize
        super('Item')
      end

      def find_by_sku(sku, fields = '*')
        response = quickbooks.query("select #{fields} from Item where Name = '#{sku}'")
        response.entries.first
      end

      def find_by_updated_at
        raise MissingTimestampParam unless SpreeQuickbooks::Config['quickbooks_poll_stock_timestamp'].present?

        filter = "Where Metadata.LastUpdatedTime > '#{SpreeQuickbooks::Config['quickbooks_poll_stock_timestamp']}'"
        order = 'Order By Metadata.LastUpdatedTime'
        response = quickbooks.query "select Name, QtyOnHand, Metadata.LastUpdatedTime from Item #{filter} #{order}"

        response.entries
      end

      # NOTE what if a product is given?
      def find_or_create_by_sku(line_item, account = nil)
        name = line_item[:sku] || line_item[:product_id]

        params = {
            name: name,
            description: line_item[:description],
            unit_price: line_item[:price],
            purchase_cost: line_item[:cost_price],
            income_account_id: account ? account.id : nil
        }

        find_by_sku(name) || create(params)
      end


    end
  end
end
