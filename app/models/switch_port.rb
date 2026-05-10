# frozen_string_literal: true

class SwitchPort < ApplicationRecord
  NAME_MAX_LENGTH = 255

  belongs_to :network_switch
  has_one :patch_connection, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :network_switch_id }

  # Switch ports already in another patch (excluding +exclude+ when editing).
  scope :selectable_for_patch_connection, lambda { |exclude: nil|
    occupied = PatchConnection.all
    occupied = occupied.where.not(id: exclude.id) if exclude&.persisted?
    where.not(id: occupied.select(:switch_port_id))
  }

  # Sort: purely numeric names first (1, 2, 10…); then names with a trailing digit run (Gi1/0/1…); then the rest.
  def self.sort_ports_for_display(relation)
    relation.to_a.sort_by(&:display_sort_key)
  end

  def select_label
    "#{network_switch.name} — #{name}"
  end

  def display_sort_key
    n = name.to_s
    if n.match?(/\A\d+\z/)
      [0, "", n.to_i]
    elsif (md = n.match(/(\d+)\z/))
      [1, md.pre_match, md[1].to_i]
    else
      [2, n, 0]
    end
  end
end
