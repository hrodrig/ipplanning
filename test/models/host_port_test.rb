# frozen_string_literal: true

require "test_helper"

class HostPortTest < ActiveSupport::TestCase
  test "valid host port" do
    hp = HostPort.new(host: hosts(:two), name: "ens160", port_kind: "physical")
    assert hp.valid?
  end

  test "rejects invalid mac" do
    hp = HostPort.new(host: hosts(:two), name: "e1", port_kind: "physical", mac_address: "not-a-mac")
    assert_not hp.valid?
    assert hp.errors[:mac_address].present?
  end

  test "unique name per host" do
    hp = HostPort.new(host: hosts(:one), name: "eth0", port_kind: "logical")
    assert_not hp.valid?
  end
end
