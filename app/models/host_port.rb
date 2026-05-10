# frozen_string_literal: true

class HostPort < ApplicationRecord
  PORT_KINDS = %w[physical logical].freeze

  belongs_to :host
  has_one :patch_connection, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :host_id }
  validates :port_kind, inclusion: { in: PORT_KINDS }
  validate :mac_address_format

  def port_kind_label
    I18n.t("host_port_kind_#{port_kind}", default: port_kind.humanize)
  end

  def display_label
    "#{name} · #{port_kind_label}"
  end

  private

  def mac_address_format
    return if mac_address.blank?

    unless mac_address.strip.match?(/\A(?:[0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}\z/)
      errors.add(:mac_address, :invalid_mac)
    end
  end
end
