# frozen_string_literal: true

class Location < ApplicationRecord
  has_many :server_racks, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
end
