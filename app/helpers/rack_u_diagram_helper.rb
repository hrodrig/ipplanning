# frozen_string_literal: true

module RackUDiagramHelper
  MAX_RACK_U = 60
  DEFAULT_RACK_U = 42

  # Human-readable span e.g. "U21" or "U21–22" (bottom U first, counting up).
  def host_rack_u_range_label(host)
    return nil unless host.rack_mount?
    return nil if host.rack_position_start.blank? || host.rack_units.blank?

    s = host.rack_position_start.to_i
    n = host.rack_units.to_i
    return nil if s < 1 || n < 1

    e = s + n - 1
    (s == e) ? "U#{s}" : "U#{s}–#{e}"
  end

  # Rows top → bottom in the UI = U{height} down to U1 (physical front view).
  def rack_u_diagram_rows(server_rack, highlight_host: nil)
    height = effective_rack_height(server_rack)
    occupancy = rack_u_occupancy_map(server_rack, height)

    height.downto(1).map do |u|
      hosts_here = occupancy[u] || []
      {
        u: u,
        hosts: hosts_here,
        focused: highlight_host.present? && hosts_here.include?(highlight_host)
      }
    end
  end

  def rack_hosts_missing_placement(server_rack)
    server_rack.hosts.select do |h|
      h.rack_mount? && (h.rack_position_start.blank? || h.rack_units.blank? || h.rack_position_start.to_i < 1 || h.rack_units.to_i < 1)
    end
  end

  private

  def effective_rack_height(server_rack)
    h = server_rack.u_height.presence&.to_i
    h = DEFAULT_RACK_U if h.blank? || h < 1
    h = [h, MAX_RACK_U].min

    max_top = server_rack.hosts.filter_map do |host|
      next unless host.rack_mount?
      next if host.rack_position_start.blank? || host.rack_units.blank?

      s = host.rack_position_start.to_i
      n = host.rack_units.to_i
      next if s < 1 || n < 1

      s + n - 1
    end.max

    return h if max_top.blank?

    [[h, max_top].max, MAX_RACK_U].min
  end

  # rack_position_start = lowest U occupied (U1 = bottom of rack).
  def rack_u_occupancy_map(server_rack, height)
    map = Hash.new { |hh, k| hh[k] = [] }
    server_rack.hosts.each do |host|
      next unless host.rack_mount?
      next if host.rack_position_start.blank? || host.rack_units.blank?

      s = host.rack_position_start.to_i
      n = host.rack_units.to_i
      next if s < 1 || n < 1

      (s...(s + n)).each do |u|
        next if u > height || u < 1

        map[u] << host
      end
    end
    map.transform_values { |list| list.uniq }
  end
end
