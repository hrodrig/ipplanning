require "test_helper"

class HostTest < ActiveSupport::TestCase
  setup { AppSettings.clear_cache! }

  test "rack_mount requires rack and rack_units" do
    h = Host.new(
      name: "rack-test-host",
      description: "x",
      hosts_type: "Physical Host",
      deployment_form: Host::RACK_MOUNT,
      environment: environments(:one),
      infrastructure: infrastructures(:one),
      host_type: host_types(:one)
    )
    assert_not h.valid?
    assert h.errors[:server_rack_id].present?
    assert h.errors[:rack_units].present?

    h.server_rack = server_racks(:one)
    h.rack_units = 1
    assert h.valid?
  end

  test "non-rack deployment clears rack fields on save" do
    h = hosts(:two)
    h.deployment_form = "tower"
    h.save!
    h.reload
    assert_nil h.server_rack_id
    assert_nil h.rack_units
    assert_nil h.rack_position_start
  end

  test "all_ips and all_ips_except_this return plain comma separated addresses" do
    h = hosts(:one)
    a = Ip.create!(vlan: vlans(:one), address: "192.168.10.61", include_in_etc_hosts: true, use_vlan_descriptor: false, use_domain_name: false, is_reserved: false)
    b = Ip.create!(vlan: vlans(:one), address: "192.168.10.62", include_in_etc_hosts: true, use_vlan_descriptor: false, use_domain_name: false, is_reserved: false)
    h.ips << [a, b]

    assert_equal "192.168.10.61, 192.168.10.62", h.all_ips
    assert_equal "192.168.10.62", h.all_ips_except_this("192.168.10.61")
  end
end
