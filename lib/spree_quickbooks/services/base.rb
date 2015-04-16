module SpreeQuickbooks
  module Services
    class Base
      attr_reader :model_name, :quickbooks

      def initialize(model_name)
        @model_name = model_name
        @quickbooks = create_access_service
      end

      def create(attributes = {})
        model = fill(create_model, attributes)
        quickbooks.create model
      end

      def update(model, attributes = {})
        quickbooks.update fill(model, attributes)
      end

      def create_model
        "Quickbooks::Model::#{model_name}".constantize.new
      end

      protected

      def lookup_value!(hash, key, ignore_case = false, default = nil)
        hash = Hash[hash.map{|k,v| [k.downcase,v]}] if ignore_case

        if default
          value = hash.fetch(key, default)
        else
          value = hash[key]
        end

        value || (raise LookupValueNotFoundException.new("Can't find the key '#{key}' in the provided mapping"))
      end

      def self.payment_method_names service
        fetch_names_hash service
      end

      def self.customer_names service
        fetch_names_hash service
      end




      private

      def fill(item, attributes)
        attributes.each {|key, value| item.send("#{key}=", value)}
        item
      end

      def self.fetch_names_hash service
        data = {}
        page = 1
        per_page = 20
        list = service.list([],page,per_page)
        while(list.count != 0) do
          list.entries.each do |entry|
            data[entry.id.value] = entry.name
          end
          page += 1
          list = service.list([],page,per_page)
        end
        data
      end


      def create_access_service
        service = "Quickbooks::Service::#{@model_name}".constantize.new
        service.access_token = access_token
        service.company_id = SpreeQuickbooks::Config[:quickbooks_realm]
        service
      end

      def access_token
        @access_token ||= SpreeQuickbooks::Services::Auth.new(
            token: SpreeQuickbooks::Config[:quickbooks_access_token] ,
            secret: SpreeQuickbooks::Config[:quickbooks_access_secret]
        ).access_token
      end

    end
  end
end