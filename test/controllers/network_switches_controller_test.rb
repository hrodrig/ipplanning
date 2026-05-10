# frozen_string_literal: true

require "test_helper"

class NetworkSwitchesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @network_switch = network_switches(:one)
    sign_in admins(:one)
  end

  test "should get index" do
    get network_switches_url
    assert_response :success
  end

  test "should get new" do
    get new_network_switch_url
    assert_response :success
  end

  test "should create network_switch and ports" do
    assert_difference("NetworkSwitch.count") do
      assert_difference("SwitchPort.count", 3) do
        post network_switches_url, params: {
          network_switch: {
            name: "SW-NEW-#{Time.now.to_i}",
            equipment_model: "Cisco 2600",
            server_rack_id: server_racks(:two).id,
            rack_units: 1,
            port_count: 3
          }
        }
      end
    end

    sw = NetworkSwitch.order(:created_at).last
    assert_redirected_to network_switch_url(sw)
    assert_equal "Cisco 2600", sw.equipment_model
    assert_equal %w[1 2 3], sw.switch_ports_ordered_for_display.map(&:name)
  end

  test "should create network_switch with default port name template" do
    assert_difference("NetworkSwitch.count") do
      assert_difference("SwitchPort.count", 3) do
        post network_switches_url, params: {
          network_switch: {
            name: "SW-TPL-#{Time.now.to_i}",
            server_rack_id: server_racks(:two).id,
            rack_units: 1,
            port_count: 3,
            default_port_name_template: "Gi1/0/1"
          }
        }
      end
    end

    sw = NetworkSwitch.order(:created_at).last
    assert_redirected_to network_switch_url(sw)
    assert_equal %w[Gi1/0/1 Gi1/0/2 Gi1/0/3], sw.switch_ports_ordered_for_display.map(&:name)
  end

  test "should show network_switch" do
    get network_switch_url(@network_switch)
    assert_response :success
  end

  test "should get edit" do
    get edit_network_switch_url(@network_switch)
    assert_response :success
  end

  test "should update network_switch" do
    patch network_switch_url(@network_switch), params: {
      network_switch: { notes: "Updated" }
    }
    assert_redirected_to network_switch_url(@network_switch)
    assert_equal "Updated", @network_switch.reload.notes
  end

  test "should destroy network_switch" do
    to_destroy = NetworkSwitch.create!(
      name: "SW-TEMP-DEL-#{Time.now.to_i}",
      server_rack: server_racks(:two),
      rack_units: 1
    )

    assert_difference("NetworkSwitch.count", -1) do
      delete network_switch_url(to_destroy)
    end

    assert_redirected_to network_switches_url
  end
end
