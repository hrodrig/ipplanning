# frozen_string_literal: true

require "test_helper"

class LocationTest < ActiveSupport::TestCase
  test "requires name" do
    loc = Location.new(name: "")
    assert_not loc.valid?
    assert loc.errors[:name].present?
  end

  test "name must be unique" do
    loc = Location.new(name: locations(:one).name)
    assert_not loc.valid?
    assert loc.errors[:name].present?
  end
end
