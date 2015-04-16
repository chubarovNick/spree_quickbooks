# Run Coverage report
require 'simplecov'
SimpleCov.start do
  add_filter 'spec/dummy'
  add_group 'Controllers', 'app/controllers'
  add_group 'Helpers', 'app/helpers'
  add_group 'Mailers', 'app/mailers'
  add_group 'Models', 'app/models'
  add_group 'Views', 'app/views'
  add_group 'Libraries', 'lib'
end

# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

require File.expand_path('../dummy/config/environment.rb',  __FILE__)

require 'rspec/rails'
require 'database_cleaner'
require 'ffaker'
require 'vcr'
require 'dotenv'
Dotenv.load

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each { |f| require f }

# Requires factories and other useful helpers defined in spree_core.
require 'spree/testing_support/authorization_helpers'
require 'spree/testing_support/capybara_ext'
require 'spree/testing_support/controller_requests'
require 'spree/testing_support/factories'
require 'spree/testing_support/url_helpers'

# Requires factories defined in lib/spree_quickbooks/factories.rb
require 'spree_quickbooks/factories'

VCR.configure do |c|
  # c.allow_http_connections_when_no_cassette = true
  c.cassette_library_dir = 'spec/vcr_cassettes'
  c.hook_into :webmock

  c.filter_sensitive_data('oauth_consumer_key') { |_| ENV['QB_CONSUMER_KEY'] }
  c.filter_sensitive_data('oauth_token')        { |_| ENV['QB_CONSUMER_SECRET'].gsub('@','%40') }
end

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods

  # Infer an example group's spec type from the file location.
  config.infer_spec_type_from_file_location!

  # == URL Helpers
  #
  # Allows access to Spree's routes in specs:
  #
  # visit spree.admin_path
  # current_path.should eql(spree.products_path)
  config.include Spree::TestingSupport::UrlHelpers

  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec
  config.color = true

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # Capybara javascript drivers require transactional fixtures set to false, and we use DatabaseCleaner
  # to cleanup after each test instead.  Without transactional fixtures set to false the records created
  # to setup a test will be unavailable to the browser, which runs under a separate server instance.
  config.use_transactional_fixtures = false

  # Ensure Suite is set to use transactions for speed.
  config.before :suite do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with :truncation
  end

  # Before each spec check if it is a Javascript test and switch between using database transactions or not where necessary.
  config.before :each do
    DatabaseCleaner.strategy = RSpec.current_example.metadata[:js] ? :truncation : :transaction
    DatabaseCleaner.start
  end

  # After each spec clean the database.
  config.after :each do
    DatabaseCleaner.clean
  end

  SpreeQuickbooks::Config[:quickbooks_access_token] = Factories.config['quickbooks_access_token']
  SpreeQuickbooks::Config[:quickbooks_access_secret] = Factories.config['quickbooks_access_secret']
  SpreeQuickbooks::Config[:quickbooks_realm] = Factories.config['quickbooks_realm']
  SpreeQuickbooks::Config[:quickbooks_poll_stock_timestamp] = Factories.config['quickbooks_poll_stock_timestamp']
  SpreeQuickbooks::Config[:quickbooks_payment_method_name] = Factories.config['quickbooks_payment_method_name']
  SpreeQuickbooks::Config[:quickbooks_deposit_to_account_name] = Factories.config['quickbooks_deposit_to_account_name']

  config.fail_fast = ENV['FAIL_FAST'] || false
  config.order = "random"
end
