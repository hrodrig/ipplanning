# frozen_string_literal: true

class AddBrandMarkSetting < ActiveRecord::Migration[8.0]
  def up
    return if Setting.where(name: "BrandMark").exists?

    Setting.create!(
      name: "BrandMark",
      value: "",
      description: "Optional URL or path for the small logo next to the navbar brand. Leave empty to use the default mark."
    )
  end

  def down
    Setting.where(name: "BrandMark").delete_all
  end
end
