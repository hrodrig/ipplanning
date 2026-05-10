# frozen_string_literal: true

require "test_helper"

class HostPortsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @host = hosts(:two)
    sign_in admins(:one)
  end

  test "should create host port" do
    assert_difference("HostPort.count") do
      post host_host_ports_url(@host), params: {
        host_port: { name: "eth-test", port_kind: "physical", mac_address: "", notes: "" }
      }
    end
    assert_redirected_to host_url(@host)
  end
end
