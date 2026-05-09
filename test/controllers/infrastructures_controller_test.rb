require 'test_helper'

class InfrastructuresControllerTest < ActionDispatch::IntegrationTest
  setup do
    @infrastructure = infrastructures(:one)
    sign_in admins(:one)
  end

  test "should get index" do
    get infrastructures_url
    assert_response :success
  end

  test "should get new" do
    get new_infrastructure_url
    assert_response :success
  end

  test "should create infrastructure" do
    assert_difference('Infrastructure.count') do
      post infrastructures_url, params: { infrastructure: { name: "Infrastructure #{Time.now.to_i}" } }
    end

    assert_redirected_to infrastructure_url(Infrastructure.last)
  end

  test "should show infrastructure" do
    get infrastructure_url(@infrastructure)
    assert_response :success
  end

  test "should get edit" do
    get edit_infrastructure_url(@infrastructure)
    assert_response :success
  end

  test "should update infrastructure" do
    patch infrastructure_url(@infrastructure), params: { infrastructure: { name: @infrastructure.name } }
    assert_redirected_to infrastructure_url(@infrastructure)
  end

  test "should destroy infrastructure" do
    @infrastructure_to_destroy = Infrastructure.create(name: "Infrastructure to destroy")
    assert_difference('Infrastructure.count', -1) do
      delete infrastructure_url(@infrastructure_to_destroy)
    end

    assert_redirected_to infrastructures_url
  end
end
