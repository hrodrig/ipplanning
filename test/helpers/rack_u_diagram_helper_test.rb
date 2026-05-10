# frozen_string_literal: true

require "test_helper"
require "securerandom"

class RackUDiagramHelperTest < ActionView::TestCase
  include RackUDiagramHelper

  test "host_rack_u_range_label spans bottom to top Us" do
    host = Host.new(deployment_form: Host::RACK_MOUNT, rack_position_start: 21, rack_units: 2)
    assert_equal "U21–22", host_rack_u_range_label(host)
  end

  test "rack_u_diagram_rows marks focused host Us" do
    suffix = SecureRandom.hex(4)
    loc = locations(:one)
    rack = ServerRack.create!(location: loc, name: "diag-rack-#{suffix}", u_height: 24)
    h_focus = Host.create!(
      name: "focus-#{suffix}",
      description: "x",
      hosts_type: "Physical Host",
      deployment_form: Host::RACK_MOUNT,
      server_rack: rack,
      rack_units: 2,
      rack_position_start: 5,
      environment: environments(:one),
      infrastructure: infrastructures(:one),
      host_type: host_types(:one)
    )
    Host.create!(
      name: "other-#{suffix}",
      description: "x",
      hosts_type: "Physical Host",
      deployment_form: Host::RACK_MOUNT,
      server_rack: rack,
      rack_units: 1,
      rack_position_start: 12,
      environment: environments(:one),
      infrastructure: infrastructures(:one),
      host_type: host_types(:two)
    )

    rows = rack_u_diagram_rows(rack, highlight_host: h_focus)
    row5 = rows.find { |r| r[:u] == 5 }
    row6 = rows.find { |r| r[:u] == 6 }
    row12 = rows.find { |r| r[:u] == 12 }

    assert row5[:focused]
    assert row6[:focused]
    assert_not row12[:focused]
    assert row12[:hosts].any?
    assert row5[:switches].empty?
    assert row12[:switches].empty?
  end

  test "network_switch_rack_u_range_label spans bottom to top Us" do
    sw = NetworkSwitch.new(server_rack_id: 1, rack_position_start: 29, rack_units: 2)
    assert_equal "U29–30", network_switch_rack_u_range_label(sw)
  end

  test "rack_u_diagram_rows includes network switches and focus highlight" do
    suffix = SecureRandom.hex(4)
    loc = locations(:one)
    rack = ServerRack.create!(location: loc, name: "diag-rack-sw-#{suffix}", u_height: 42)
    NetworkSwitch.create!(
      name: "sw-diag-#{suffix}",
      server_rack: rack,
      rack_units: 2,
      rack_position_start: 29
    )
    rack.reload

    sw = rack.network_switches.sole
    rows = rack_u_diagram_rows(rack, highlight_network_switch: sw)
    row29 = rows.find { |r| r[:u] == 29 }
    row30 = rows.find { |r| r[:u] == 30 }
    row31 = rows.find { |r| r[:u] == 31 }

    assert_includes row29[:switches], sw
    assert_includes row30[:switches], sw
    assert row29[:focused]
    assert row30[:focused]
    assert_not row31[:focused]
    assert row31[:switches].empty?
  end
end
