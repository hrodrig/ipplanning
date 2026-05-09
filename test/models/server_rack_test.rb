# frozen_string_literal: true

require "test_helper"

class ServerRackTest < ActiveSupport::TestCase
  test "requires name" do
    rack = ServerRack.new(location: locations(:one), name: "")
    assert_not rack.valid?
    assert rack.errors[:name].present?
  end

  test "name unique within location" do
    rack = ServerRack.new(location: locations(:one), name: server_racks(:one).name)
    assert_not rack.valid?
    assert rack.errors[:name].present?
  end

  test "same name allowed in different locations" do
    rack = ServerRack.new(location: locations(:two), name: server_racks(:one).name)
    assert rack.valid?
  end

  test "u_height must be positive when present" do
    rack = ServerRack.new(location: locations(:one), name: "X", u_height: 0)
    assert_not rack.valid?
  end

  test "cannot destroy rack while hosts reference it" do
    rack = server_racks(:one)
    assert Host.exists?(server_rack_id: rack.id)
    assert_not rack.destroy
    assert rack.errors[:base].present?
  end
end
