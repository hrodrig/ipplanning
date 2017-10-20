require 'test_helper'

class VlansControllerTest < ActionDispatch::IntegrationTest
  setup do
    @vlan = vlans(:one)
  end

  test "should get index" do
    get vlans_url
    assert_response :success
  end

  test "should get new" do
    get new_vlan_url
    assert_response :success
  end

  test "should create vlan" do
    assert_difference('Vlan.count') do
      post vlans_url, params: { vlan: { gateway: @vlan.gateway, name: @vlan.name, netmask: @vlan.netmask, network: @vlan.network, notes: @vlan.notes, number: @vlan.number } }
    end

    assert_redirected_to vlan_url(Vlan.last)
  end

  test "should show vlan" do
    get vlan_url(@vlan)
    assert_response :success
  end

  test "should get edit" do
    get edit_vlan_url(@vlan)
    assert_response :success
  end

  test "should update vlan" do
    patch vlan_url(@vlan), params: { vlan: { gateway: @vlan.gateway, name: @vlan.name, netmask: @vlan.netmask, network: @vlan.network, notes: @vlan.notes, number: @vlan.number } }
    assert_redirected_to vlan_url(@vlan)
  end

  test "should destroy vlan" do
    assert_difference('Vlan.count', -1) do
      delete vlan_url(@vlan)
    end

    assert_redirected_to vlans_url
  end
end
