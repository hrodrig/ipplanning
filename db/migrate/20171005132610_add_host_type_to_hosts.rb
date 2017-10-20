class AddHostTypeToHosts < ActiveRecord::Migration[5.1]
  def change
    add_reference :hosts, :host_type, foreign_key: true
  end
end
