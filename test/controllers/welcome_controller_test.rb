require 'test_helper'

class WelcomeControllerTest < ActionDispatch::IntegrationTest
  test "should redirect to sign in when not authenticated" do
    get root_url
    assert_response :redirect
    assert_match %r{/admins/sign_in}, response.redirect_url
  end

  test "should get index when signed in as admin" do
    sign_in admins(:one)
    get root_url
    assert_response :success
  end
end
