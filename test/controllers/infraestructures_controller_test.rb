require 'test_helper'

class InfraestructuresControllerTest < ActionDispatch::IntegrationTest
  setup do
    @infraestructure = infraestructures(:one)
    sign_in admins(:one)
  end

  test "should get index" do
    get infraestructures_url
    assert_response :success
  end

  test "should get new" do
    get new_infraestructure_url
    assert_response :success
  end

  test "should create infraestructure" do
    assert_difference('Infraestructure.count') do
      post infraestructures_url, params: { infraestructure: { name: @infraestructure.name } }
    end

    assert_redirected_to infraestructure_url(Infraestructure.last)
  end

  test "should show infraestructure" do
    get infraestructure_url(@infraestructure)
    assert_response :success
  end

  test "should get edit" do
    get edit_infraestructure_url(@infraestructure)
    assert_response :success
  end

  test "should update infraestructure" do
    patch infraestructure_url(@infraestructure), params: { infraestructure: { name: @infraestructure.name } }
    assert_redirected_to infraestructure_url(@infraestructure)
  end

  test "should destroy infraestructure" do
    @infraestructure_to_destroy = Infraestructure.create(name: "Infraestructure to destroy")
    assert_difference('Infraestructure.count', -1) do
      delete infraestructure_url(@infraestructure_to_destroy)
    end

    assert_redirected_to infraestructures_url
  end
end
