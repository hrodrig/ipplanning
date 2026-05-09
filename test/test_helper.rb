require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

# Match ApplicationController#default_url_options so *_url helpers and redirect assertions
# include ?locale=en (or the current default locale).
Rails.application.routes.default_url_options[:locale] = I18n.default_locale

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  include Devise::Test::IntegrationHelpers

  # Add more helper methods to be used by all tests here...
end
