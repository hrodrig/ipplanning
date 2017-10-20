class AddEnvironmentToHosts < ActiveRecord::Migration[5.1]
  def change
    add_reference :hosts, :environment, foreign_key: true
  end
end
