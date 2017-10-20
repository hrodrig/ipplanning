class AddShortHostnameToExternalips < ActiveRecord::Migration[5.1]
  def change
    add_column :externalips, :short_hostname, :string
  end
end
