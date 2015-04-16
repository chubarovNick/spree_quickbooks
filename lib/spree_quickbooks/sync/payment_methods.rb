module SpreeQuickbooks
  module Sync
    class PaymentMethods
      attr_reader :payment_method_service

      #TODO More usefull service
      def initialize
        @payment_method_service = SpreeQuickbooks::Services::PaymentMethod.new({})
      end

      def perform
        Spree::PaymentMethod.all.each do |payment_method|
          payment_method_service.create(name: payment_method)
        end
      end
    end
  end
end