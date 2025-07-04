class ChangeEmployeeNumberToStringInUsers < ActiveRecord::Migration[7.0]
  def up
    change_column :users, :employee_number, :string, null: false, using: 'employee_number::text'
  end

  def down
    change_column :users, :employee_number, :integer, null: false, using: 'employee_number::integer'
  end
end
