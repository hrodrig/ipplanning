# frozen_string_literal: true

module RackUDiagramHelper
  MAX_RACK_U = 60
  DEFAULT_RACK_U = 42

  # Human-readable span e.g. "U21" or "U21–22" (bottom U first, counting up).
  def host_rack_u_range_label(host)
    return nil unless host.rack_mount?

    rack_u_span_label(host.rack_position_start, host.rack_units)
  end

  def network_switch_rack_u_range_label(network_switch)
    return nil if network_switch.server_rack_id.blank?

    rack_u_span_label(network_switch.rack_position_start, network_switch.rack_units)
  end

  # Rows top → bottom in the UI = U{height} down to U1 (physical front view).
  def rack_u_diagram_rows(server_rack, highlight_host: nil, highlight_network_switch: nil)
    height = effective_rack_height(server_rack)
    occupancy = rack_u_occupancy_map(server_rack, height)

    height.downto(1).map do |u|
      cell = occupancy[u] || { hosts: [], switches: [] }
      hosts_here = cell[:hosts]
      switches_here = cell[:switches]
      focused_host = highlight_host.present? && hosts_here.include?(highlight_host)
      focused_switch = highlight_network_switch.present? && switches_here.include?(highlight_network_switch)

      {
        u: u,
        hosts: hosts_here,
        switches: switches_here,
        focused: focused_host || focused_switch
      }
    end
  end

  def rack_hosts_missing_placement(server_rack)
    server_rack.hosts.select do |h|
      h.rack_mount? && (h.rack_position_start.blank? || h.rack_units.blank? || h.rack_position_start.to_i < 1 || h.rack_units.to_i < 1)
    end
  end

  def rack_network_switches_missing_placement(server_rack)
    server_rack.network_switches.select do |sw|
      sw.rack_position_start.blank? || sw.rack_units.blank? || sw.rack_position_start.to_i < 1 || sw.rack_units.to_i < 1
    end
  end

  private

  def rack_u_span_label(position_start, units)
    return nil if position_start.blank? || units.blank?

    s = position_start.to_i
    n = units.to_i
    return nil if s < 1 || n < 1

    e = s + n - 1
    (s == e) ? "U#{s}" : "U#{s}–#{e}"
  end

  def effective_rack_height(server_rack)
    h = server_rack.u_height.presence&.to_i
    h = DEFAULT_RACK_U if h.blank? || h < 1
    h = [h, MAX_RACK_U].min

    max_top = [
      max_top_from_hosts(server_rack.hosts),
      max_top_from_network_switches(server_rack.network_switches)
    ].compact.max

    return h if max_top.blank?

    [[h, max_top].max, MAX_RACK_U].min
  end

  def max_top_from_hosts(hosts)
    hosts.filter_map do |host|
      next unless host.rack_mount?
      next if host.rack_position_start.blank? || host.rack_units.blank?

      s = host.rack_position_start.to_i
      n = host.rack_units.to_i
      next if s < 1 || n < 1

      s + n - 1
    end.max
  end

  def max_top_from_network_switches(switches)
    switches.filter_map do |sw|
      next if sw.rack_position_start.blank? || sw.rack_units.blank?

      s = sw.rack_position_start.to_i
      n = sw.rack_units.to_i
      next if s < 1 || n < 1

      s + n - 1
    end.max
  end

  # rack_position_start = lowest U occupied (U1 = bottom of rack).
  def rack_u_occupancy_map(server_rack, height)
    map = Hash.new { |hh, k| hh[k] = { hosts: [], switches: [] } }

    server_rack.hosts.each do |host|
      next unless host.rack_mount?
      next if host.rack_position_start.blank? || host.rack_units.blank?

      s = host.rack_position_start.to_i
      n = host.rack_units.to_i
      next if s < 1 || n < 1

      (s...(s + n)).each do |u|
        next if u > height || u < 1

        map[u][:hosts] << host
      end
    end

    server_rack.network_switches.each do |sw|
      next if sw.rack_position_start.blank? || sw.rack_units.blank?

      s = sw.rack_position_start.to_i
      n = sw.rack_units.to_i
      next if s < 1 || n < 1

      (s...(s + n)).each do |u|
        next if u > height || u < 1

        map[u][:switches] << sw
      end
    end

    map.transform_values do |v|
      { hosts: v[:hosts].uniq, switches: v[:switches].uniq }
    end
  end
end
