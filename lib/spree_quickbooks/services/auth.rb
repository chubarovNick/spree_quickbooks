module SpreeQuickbooks
  module Services
    class Auth
      attr_reader :token, :secret

      def initialize(credentials = {})
        Quickbooks.sandbox_mode = (SpreeQuickbooks::Config[:mode] == 'test')
        if Quickbooks.sandbox_mode
          Quickbooks.log = true
          Quickbooks.logger = Rails.logger
        end
        @token = credentials[:token]
        @secret = credentials[:secret]
      end

      def access_token
        @access_token ||= OAuth::AccessToken.new(consumer, token, secret)
      end

      private

      def consumer
        OAuth::Consumer.new(SpreeQuickbooks::Config[:quickbooks_key], SpreeQuickbooks::Config[:quickbooks_secret],
                            site: 'https://oauth.intuit.com',
                            request_token_path: '/oauth/v1/get_request_token',
                            authorize_url: 'https://appcenter.intuit.com/Connect/Begin',
                            access_token_path: '/oauth/v1/get_access_token')
      end
    end
  end
end