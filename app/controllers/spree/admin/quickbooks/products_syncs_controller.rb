module Spree
  module Admin
    module Quickbooks
      class ProductsSyncsController < Spree::Admin::BaseController

        def create
          SpreeQuickbooks::Sync::Products.new.perform
          redirect_to admin_quickbooks_path
        end


      end
    end
  end
end