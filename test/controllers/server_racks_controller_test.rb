# frozen_string_literal: true

require "test_helper"

class ServerRacksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @server_rack = server_racks(:one)
    sign_in admins(:one)
  end

  test "should get index" do
    get server_racks_url
    assert_response :success
  end

  test "should get new" do
    get new_server_rack_url
    assert_response :success
  end

  test "should create server_rack" do
    assert_difference("ServerRack.count") do
      post server_racks_url, params: {
        server_rack: {
          location_id: locations(:one).id,
          name: "RACK-NEW-#{Time.now.to_i}",
          u_height: 24
        }
      }
    end

    assert_redirected_to server_rack_url(ServerRack.last)
  end

  test "should show server_rack" do
    get server_rack_url(@server_rack)
    assert_response :success
  end

  test "should get edit" do
    get edit_server_rack_url(@server_rack)
    assert_response :success
  end

  test "should update server_rack" do
    patch server_rack_url(@server_rack), params: {
      server_rack: { name: @server_rack.name, notes: "Updated notes" }
    }
    assert_redirected_to server_rack_url(@server_rack)
  end

  test "should destroy server_rack" do
    to_destroy = ServerRack.create!(location: locations(:two), name: "Temp rack destroy")
    assert_difference("ServerRack.count", -1) do
      delete server_rack_url(to_destroy)
    end

    assert_redirected_to server_racks_url
  end

  test "should not destroy server_rack with assigned hosts and show alert" do
    rack = server_racks(:one)
    assert Host.exists?(server_rack_id: rack.id)

    assert_no_difference("ServerRack.count") do
      delete server_rack_url(rack)
    end

    assert_redirected_to server_racks_url
    assert_not_nil flash[:alert]
    follow_redirect!
    assert_response :success
    assert_includes @response.body, I18n.t("server_rack_destroy_blocked_hosts", name: rack.name, count: rack.hosts.count)
  end
end
