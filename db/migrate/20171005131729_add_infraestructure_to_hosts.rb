class AddInfraestructureToHosts < ActiveRecord::Migration[5.1]
  def change
    add_reference :hosts, :infraestructure, foreign_key: true
  end
end
