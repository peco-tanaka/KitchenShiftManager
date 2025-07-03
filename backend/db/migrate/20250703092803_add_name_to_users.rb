class AddNameToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :last_name, :string, null: false, limit: 50
    add_column :users, :first_name, :string, null: false, limit: 50
  end
end
