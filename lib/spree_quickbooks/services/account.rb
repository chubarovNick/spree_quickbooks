module SpreeQuickbooks
  module Services
    class Account < Base

      def initialize
        super('Account')
      end

      def find_by_name(account_name)
        account = @quickbooks.query("select * from Account where Name = '#{account_name}'").entries.first
        raise "No Account '#{account_name}' defined in service" unless account

        account
      end

    end
  end
end