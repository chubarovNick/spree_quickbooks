module Spree
  module Admin
    class QuickbooksController < BaseController

      def show

      end

      def authenticate
        callback = oauth_callback_admin_quickbooks_url
        token = consumer.get_request_token(:oauth_callback => callback)
        session[:qb_request_token] = Marshal.dump(token)
        redirect_to("https://appcenter.intuit.com/Connect/Begin?oauth_token=#{token.token}") and return
      end

      def oauth_callback
        at = Marshal.load(session[:qb_request_token]).get_access_token(:oauth_verifier => params[:oauth_verifier])
        SpreeQuickbooks::Config[:quickbooks_realm] = params['realmId']
        SpreeQuickbooks::Config[:quickbooks_access_token] = at.token
        SpreeQuickbooks::Config[:quickbooks_access_secret] = at.secret
        redirect_to admin_quickbooks_url, notice: 'Your QuickBooks account has been successfully linked.'
      end

      private

      def consumer
        OAuth::Consumer.new(SpreeQuickbooks::Config[:quickbooks_key], SpreeQuickbooks::Config[:quickbooks_secret], {
                                                                        :site => 'https://oauth.intuit.com',
                                                                        :request_token_path => '/oauth/v1/get_request_token',
                                                                        :authorize_url => 'https://appcenter.intuit.com/Connect/Begin',
                                                                        :access_token_path => '/oauth/v1/get_access_token'
                                                                    })
      end
    end
  end
end




