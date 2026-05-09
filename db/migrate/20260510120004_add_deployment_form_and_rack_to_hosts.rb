# frozen_string_literal: true

class AddDeploymentFormAndRackToHosts < ActiveRecord::Migration[8.0]
  def up
    unless column_exists?(:hosts, :deployment_form)
      add_column :hosts, :deployment_form, :string, null: false, default: "other"
    end

    if column_exists?(:hosts, :server_rack_id)
      add_foreign_key :hosts, :server_racks unless foreign_key_exists?(:hosts, :server_racks)
    else
      add_reference :hosts, :server_rack, foreign_key: true
    end

    unless column_exists?(:hosts, :rack_units)
      add_column :hosts, :rack_units, :integer
    end

    unless column_exists?(:hosts, :rack_position_start)
      add_column :hosts, :rack_position_start, :integer
    end

    # MySQL runs one statement per execute; do not batch multiple UPDATEs.
    execute "UPDATE hosts SET deployment_form = 'cloud_vm' WHERE hosts_type = 'Virtual Host'"
    execute "UPDATE hosts SET deployment_form = 'tower' WHERE hosts_type = 'Physical Host'"
  end

  def down
    if foreign_key_exists?(:hosts, :server_racks)
      remove_foreign_key :hosts, :server_racks
    end
    remove_column :hosts, :server_rack_id if column_exists?(:hosts, :server_rack_id)
    remove_column :hosts, :rack_position_start if column_exists?(:hosts, :rack_position_start)
    remove_column :hosts, :rack_units if column_exists?(:hosts, :rack_units)
    remove_column :hosts, :deployment_form if column_exists?(:hosts, :deployment_form)
  end
end
