# frozen_string_literal: true

class Location < ApplicationRecord
  validates :name, presence: true, uniqueness: true
end
