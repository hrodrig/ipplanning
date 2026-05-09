# frozen_string_literal: true

class RenameInfraestructureToInfrastructure < ActiveRecord::Migration[8.0]
  def up
    remove_foreign_key :hosts, :infraestructures
    rename_table :infraestructures, :infrastructures
    rename_column :hosts, :infraestructure_id, :infrastructure_id
    add_foreign_key :hosts, :infrastructures, column: :infrastructure_id
  end

  def down
    remove_foreign_key :hosts, :infrastructures
    rename_column :hosts, :infrastructure_id, :infraestructure_id
    rename_table :infrastructures, :infraestructures
    add_foreign_key :hosts, :infraestructures, column: :infraestructure_id
  end
end
