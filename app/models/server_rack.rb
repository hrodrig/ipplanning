# frozen_string_literal: true

class ServerRack < ApplicationRecord
  belongs_to :location
  has_many :hosts, dependent: :restrict_with_error
  has_many :network_switches, dependent: :restrict_with_error
  has_many_attached :photos

  validates :name, presence: true, uniqueness: { scope: :location_id }
  validates :u_height, numericality: { only_integer: true, greater_than: 0, allow_nil: true }
end
