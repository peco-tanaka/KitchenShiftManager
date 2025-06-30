class CreateIssues < ActiveRecord::Migration[7.2]
  def change
    create_table :issues do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.integer :status, default: 0, null: false
      t.integer :priority, default: 1, null: false
      t.integer :issue_type, default: 0, null: false
      t.string :assigned_to
      t.string :reporter
      t.date :due_date
      t.text :acceptance_criteria
      t.json :metadata
      
      t.timestamps
    end
    
    add_index :issues, :status
    add_index :issues, :priority
    add_index :issues, :issue_type
    add_index :issues, :assigned_to
    add_index :issues, :created_at
  end
end