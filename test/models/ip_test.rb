require "test_helper"

class IpTest < ActiveSupport::TestCase
  fixtures :vlans, :hosts, :settings, :environments, :infrastructures, :host_types, :ips, :externalips

  setup { AppSettings.clear_cache! }

  test "short_hostname for reserved ip uses dashed address" do
    ip = Ip.create!(
      vlan: vlans(:one),
      address: "10.0.0.7",
      is_reserved: true,
      include_in_etc_hosts: true,
      use_vlan_descriptor: true,
      use_domain_name: false
    )
    assert_equal "reserved-10-0-0-7", ip.short_hostname
  end

  test "long_hostname for reserved includes vlan descriptor and domain when enabled" do
    ip = Ip.create!(
      vlan: vlans(:one),
      address: "10.10.10.5",
      is_reserved: true,
      include_in_etc_hosts: true,
      use_vlan_descriptor: true,
      use_domain_name: true
    )
    expected = "#{I18n.t('reserved').downcase}-10-10-10-5-mgmt.#{AppSettings.domain_name}"
    assert_equal expected, ip.long_hostname
  end

  test "hostname hostname_with_descriptor and text_hostname use reserved label" do
    ip = Ip.create!(
      vlan: vlans(:one),
      address: "10.0.0.8",
      is_reserved: true,
      include_in_etc_hosts: true,
      use_vlan_descriptor: false,
      use_domain_name: false
    )
    assert_equal "", ip.hostname
    assert_equal I18n.t("reserved"), ip.hostname_with_descriptor
    assert_equal I18n.t("reserved"), ip.text_hostname_with_descriptor
  end

  test "ip with host and no alias uses host name and vlan descriptor in short_hostname" do
    ip = Ip.create!(
      vlan: vlans(:one),
      address: "10.0.0.30",
      hostname_alias: nil,
      complete_hostname_alias: nil,
      include_in_etc_hosts: true,
      use_vlan_descriptor: true,
      use_domain_name: true,
      is_reserved: false
    )
    hosts(:one).ips << ip
    assert_equal "web-server-01-mgmt", ip.short_hostname
    assert_equal "web-server-01", ip.hostname
    assert ip.long_hostname.end_with?(".#{AppSettings.domain_name}")
  end

  test "hostname_with_descriptor returns long_hostname when hostname_alias without host" do
    ip = Ip.create!(
      vlan: vlans(:one),
      address: "10.0.0.40",
      hostname_alias: "svc-alias",
      complete_hostname_alias: "svc-alias.#{AppSettings.domain_name}",
      include_in_etc_hosts: true,
      use_vlan_descriptor: true,
      use_domain_name: true,
      is_reserved: false
    )
    assert_nil ip.host
    assert_equal ip.long_hostname, ip.hostname_with_descriptor
  end

  test "diagnostic_agent_hostname_compliance respects short_hostname length" do
    tiny_host = Host.create!(
      name: "tiny",
      description: "short-name host",
      hosts_type: "Virtual Host",
      deployment_form: "other",
      environment: environments(:one),
      memory_size: 1024,
      total_sockets: 1,
      total_vcpus: 1,
      infrastructure: infrastructures(:one),
      host_type: host_types(:one)
    )
    short = Ip.create!(
      vlan: vlans(:one),
      address: "10.0.0.50",
      hostname_alias: nil,
      complete_hostname_alias: nil,
      include_in_etc_hosts: true,
      use_vlan_descriptor: false,
      use_domain_name: false,
      is_reserved: false
    )
    tiny_host.ips << short
    assert_equal "tiny", short.short_hostname
    assert short.diagnostic_agent_hostname_compliance?

    long = Ip.create!(
      vlan: vlans(:two),
      address: "192.168.20.51",
      hostname_alias: nil,
      complete_hostname_alias: nil,
      include_in_etc_hosts: true,
      use_vlan_descriptor: true,
      use_domain_name: false,
      is_reserved: false
    )
    hosts(:two).ips << long
    assert_equal "db-server-01-users", long.short_hostname
    assert_operator long.short_hostname.size, :>=, 13
    assert_not long.diagnostic_agent_hostname_compliance?
  end

  test "generate_etc_hosts includes fixture vlan external ip and tab separated line" do
    body = Ip.generate_etc_hosts
    assert_includes body, "# Vlan Name: Management"
    assert_includes body, "# External Ips"
    assert_match(/192\.168\.10\.1\t/, body)
    assert_match(/8\.8\.8\.8\tgoogle-public-dns\.example\.com\tgoogle-dns/, body)
    assert_match(/# this document was born in \d+\.\d+ seconds/, body)
  end
end
