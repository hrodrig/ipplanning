# frozen_string_literal: true

class PatchConnection < ApplicationRecord
  belongs_to :host_port
  belongs_to :switch_port

  validates :host_port_id, uniqueness: true
  validates :switch_port_id, uniqueness: true

  def switch_end_label
    sw = switch_port.network_switch
    "#{sw.name} · #{switch_port.name}"
  end
end
