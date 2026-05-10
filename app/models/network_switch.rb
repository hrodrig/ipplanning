# frozen_string_literal: true

class NetworkSwitch < ApplicationRecord
  MAX_DEFAULT_PORTS = 512

  belongs_to :server_rack, optional: true
  has_many :switch_ports, dependent: :destroy
  has_many_attached :photos

  before_validation :clear_rack_fields_if_no_rack

  validates :name, presence: true, uniqueness: true
  validates :rack_units, presence: true, numericality: { only_integer: true, greater_than: 0 }, if: -> { server_rack_id.present? }
  validates :rack_position_start, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  # +name_template+: optional. If blank, names are "1"…"N".
  # If it ends with digits (e.g. "Gi1/0/1"), that number is the start and increments with zero-padding width preserved.
  # If it has no trailing digits (e.g. "Gi1/0/"), appends 1, 2, … N.
  def self.build_default_port_names(count, name_template)
    n = count.to_i
    return [] if n < 1

    template = name_template.to_s.strip
    if template.empty?
      return (1..n).map(&:to_s)
    end

    names = if (md = template.match(/(\d+)\z/))
      prefix = md.pre_match
      start_str = md[1]
      start = start_str.to_i
      width = start_str.length
      (0...n).map do |i|
        num = start + i
        suffix =
          if width.positive? && num < (10**width)
            num.to_s.rjust(width, "0")
          else
            num.to_s
          end
        "#{prefix}#{suffix}"
      end
    else
      prefix = template
      (1..n).map { |i| "#{prefix}#{i}" }
    end

    if names.any? { |nm| nm.blank? || nm.bytesize > SwitchPort::NAME_MAX_LENGTH }
      raise ArgumentError, I18n.t("network_switch_port_name_template_too_long", max: SwitchPort::NAME_MAX_LENGTH)
    end

    if names.uniq.size != names.size
      raise ArgumentError, I18n.t("network_switch_port_name_template_duplicate")
    end

    names
  end

  def create_default_ports!(count, name_template: nil)
    n = count.to_i
    return if n < 1

    raise ArgumentError, "port count exceeds #{MAX_DEFAULT_PORTS}" if n > MAX_DEFAULT_PORTS

    names = self.class.build_default_port_names(n, name_template)
    now = Time.current
    rows = names.map do |name|
      { network_switch_id: id, name: name, created_at: now, updated_at: now }
    end
    SwitchPort.insert_all!(rows)
  end

  def switch_ports_ordered_for_display
    SwitchPort.sort_ports_for_display(switch_ports)
  end

  private

  def clear_rack_fields_if_no_rack
    return if server_rack_id.present?

    self.rack_units = nil
    self.rack_position_start = nil
  end
end
