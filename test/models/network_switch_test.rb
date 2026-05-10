# frozen_string_literal: true

require "test_helper"

class NetworkSwitchTest < ActiveSupport::TestCase
  test "requires name" do
    sw = NetworkSwitch.new(name: "")
    assert_not sw.valid?
    assert sw.errors.added?(:name, :blank)
  end

  test "requires rack_units when server_rack is set" do
    sw = NetworkSwitch.new(name: "sw-temp", server_rack: server_racks(:two), rack_units: nil)
    assert_not sw.valid?
  end

  test "build_default_port_names uses simple numeric names when template blank" do
    assert_equal %w[1 2 3], NetworkSwitch.build_default_port_names(3, "")
    assert_equal %w[1 2 3], NetworkSwitch.build_default_port_names(3, "   ")
  end

  test "build_default_port_names increments trailing digit run" do
    assert_equal %w[Gi1/0/1 Gi1/0/2 Gi1/0/3], NetworkSwitch.build_default_port_names(3, "Gi1/0/1")
    assert_equal %w[GigabitEthernet1/0/10 GigabitEthernet1/0/11], NetworkSwitch.build_default_port_names(2, "GigabitEthernet1/0/10")
  end

  test "build_default_port_names preserves zero padding width" do
    assert_equal %w[Gi1/0/09 Gi1/0/10 Gi1/0/11], NetworkSwitch.build_default_port_names(3, "Gi1/0/09")
  end

  test "build_default_port_names appends sequence when no trailing digits" do
    assert_equal %w[Gi1/0/1 Gi1/0/2], NetworkSwitch.build_default_port_names(2, "Gi1/0/")
  end

  test "create_default_ports! inserts numbered ports" do
    sw = NetworkSwitch.create!(
      name: "sw-ports-#{Time.now.to_i}",
      server_rack: server_racks(:two),
      rack_units: 1
    )
    assert_difference -> { sw.switch_ports.count }, 5 do
      sw.create_default_ports!(5)
    end
    assert_equal %w[1 2 3 4 5], sw.switch_ports_ordered_for_display.map(&:name)
  end

  test "create_default_ports! uses name template" do
    sw = NetworkSwitch.create!(
      name: "sw-tpl-#{Time.now.to_i}",
      server_rack: server_racks(:two),
      rack_units: 1
    )
    sw.create_default_ports!(3, name_template: "Gi1/0/48")
    assert_equal %w[Gi1/0/48 Gi1/0/49 Gi1/0/50], sw.switch_ports_ordered_for_display.map(&:name)
  end
end
