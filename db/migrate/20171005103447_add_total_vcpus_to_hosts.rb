class AddTotalVcpusToHosts < ActiveRecord::Migration[5.1]
  def change
    add_column :hosts, :total_vcpus, :integer
  end
end
