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
  end
end
