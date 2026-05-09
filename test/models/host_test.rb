require "test_helper"

class HostTest < ActiveSupport::TestCase
  fixtures :vlans, :hosts, :settings, :environments, :infrastructures, :host_types

  setup { AppSettings.clear_cache! }

  test "all_ips and all_ips_except_this return plain comma separated addresses" do
    h = hosts(:one)
    a = Ip.create!(vlan: vlans(:one), address: "10.0.1.1", include_in_etc_hosts: true, use_vlan_descriptor: false, use_domain_name: false, is_reserved: false)
    b = Ip.create!(vlan: vlans(:one), address: "10.0.1.2", include_in_etc_hosts: true, use_vlan_descriptor: false, use_domain_name: false, is_reserved: false)
    h.ips << [a, b]

    assert_equal "10.0.1.1, 10.0.1.2", h.all_ips
    assert_equal "10.0.1.2", h.all_ips_except_this("10.0.1.1")
  end
end
