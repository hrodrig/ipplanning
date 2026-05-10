# frozen_string_literal: true

require "test_helper"

class PatchConnectionTest < ActiveSupport::TestCase
  test "fixture is valid" do
    assert patch_connections(:one).valid?
  end

  test "cannot reuse switch port" do
    hp = HostPort.create!(host: hosts(:two), name: "p1", port_kind: "physical")
    pc = PatchConnection.new(host_port: hp, switch_port: switch_ports(:two))
    assert_not pc.valid?
    assert pc.errors[:switch_port_id].present?
  end

  test "cannot reuse host port" do
    pc = PatchConnection.new(host_port: host_ports(:one), switch_port: switch_ports(:one))
    assert_not pc.valid?
    assert pc.errors[:host_port_id].present?
  end
end
