require "test_helper"

class AppSettingsTest < ActiveSupport::TestCase
  fixtures :settings

  setup { AppSettings.clear_cache! }

  test "domain_name returns DomainName setting" do
    assert_equal "lab.example.test", AppSettings.domain_name
  end

  test "cache invalidates after setting update" do
    domain = settings(:domain_name)
    domain.update!(value: "other.example.test")
    assert_equal "other.example.test", AppSettings.domain_name
  end
end
