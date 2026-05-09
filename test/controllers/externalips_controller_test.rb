require 'test_helper'

class ExternalipsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @externalip = externalips(:one)
    sign_in admins(:one)
  end

  test "should get index" do
    get externalips_url
    assert_response :success
  end

  test "should get new" do
    get new_externalip_url
    assert_response :success
  end

  test "should create externalip" do
    n = Time.now.to_i
    assert_difference('Externalip.count') do
      post externalips_url, params: { externalip: {
        address: "9.9.#{n % 250}.#{n % 250}",
        include_in_etc_hosts: true,
        hostname: "ext-#{n}.example.com",
        short_hostname: "ext-#{n}",
        notes: "test"
      } }
    end

    assert_redirected_to externalip_url(Externalip.last)
  end

  test "should show externalip" do
    get externalip_url(@externalip)
    assert_response :success
  end

  test "should get edit" do
    get edit_externalip_url(@externalip)
    assert_response :success
  end

  test "should update externalip" do
    patch externalip_url(@externalip), params: { externalip: { address: @externalip.address, include_in_etc_hosts: @externalip.include_in_etc_hosts, hostname: @externalip.hostname, short_hostname: @externalip.short_hostname, notes: @externalip.notes } }
    assert_redirected_to externalips_url
  end

  test "should destroy externalip" do
    assert_difference('Externalip.count', -1) do
      delete externalip_url(@externalip)
    end

    assert_redirected_to externalips_url
  end
end
