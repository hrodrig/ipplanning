require 'test_helper'

class HostTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @host_type = host_types(:one)
  end

  test "should get index" do
    get host_types_url
    assert_response :success
  end

  test "should get new" do
    get new_host_type_url
    assert_response :success
  end

  test "should create host_type" do
    assert_difference('HostType.count') do
      post host_types_url, params: { host_type: { name: @host_type.name } }
    end

    assert_redirected_to host_type_url(HostType.last)
  end

  test "should show host_type" do
    get host_type_url(@host_type)
    assert_response :success
  end

  test "should get edit" do
    get edit_host_type_url(@host_type)
    assert_response :success
  end

  test "should update host_type" do
    patch host_type_url(@host_type), params: { host_type: { name: @host_type.name } }
    assert_redirected_to host_type_url(@host_type)
  end

  test "should destroy host_type" do
    assert_difference('HostType.count', -1) do
      delete host_type_url(@host_type)
    end

    assert_redirected_to host_types_url
  end
end
