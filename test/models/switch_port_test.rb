# frozen_string_literal: true

require "test_helper"

class SwitchPortTest < ActiveSupport::TestCase
  test "sort_ports_for_display sorts numeric port names naturally" do
    sw = network_switches(:one)
    sw.switch_ports.destroy_all
    %w[10 24 2 1 19 3 20].each { |n| SwitchPort.create!(network_switch: sw, name: n) }

    names = SwitchPort.sort_ports_for_display(sw.reload.switch_ports).map(&:name)
    assert_equal %w[1 2 3 10 19 20 24], names
  end

  test "sort_ports_for_display orders by trailing number for interface-style names" do
    sw = network_switches(:one)
    sw.switch_ports.destroy_all
    %w[Gi1/0/10 Gi1/0/2 Gi1/0/1].each { |n| SwitchPort.create!(network_switch: sw, name: n) }

    names = SwitchPort.sort_ports_for_display(sw.reload.switch_ports).map(&:name)
    assert_equal %w[Gi1/0/1 Gi1/0/2 Gi1/0/10], names
  end

  test "sort_ports_for_display puts non-numeric names after numeric and interface blocks" do
    sw = network_switches(:one)
    sw.switch_ports.destroy_all
    SwitchPort.create!(network_switch: sw, name: "2")
    SwitchPort.create!(network_switch: sw, name: "Gi1/0/1")
    SwitchPort.create!(network_switch: sw, name: "10")
    SwitchPort.create!(network_switch: sw, name: "eth-left")

    names = SwitchPort.sort_ports_for_display(sw.reload.switch_ports).map(&:name)
    assert_equal %w[2 10 Gi1/0/1 eth-left], names
  end
end
