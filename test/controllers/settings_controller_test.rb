require 'test_helper'

class SettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in admins(:one)
    @setting = settings(:website_name)
  end

  test "should get index" do
    get settings_url
    assert_response :success
  end

  test "should get edit" do
    get edit_setting_url(@setting)
    assert_response :success
  end

  test "should update setting" do
    patch setting_url(@setting), params: { setting: { description: @setting.description, name: @setting.name, value: @setting.value } }
    assert_redirected_to settings_url
  end
end
