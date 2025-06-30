class CreateReviews < ActiveRecord::Migration[7.2]
  def change
    create_table :reviews do |t|
      t.references :issue, null: false, foreign_key: true
      t.text :comment, null: false
      t.integer :status, default: 3, null: false
      t.string :reviewer_name, null: false
      t.integer :rating
      t.json :feedback_data
      
      t.timestamps
    end
    
    add_index :reviews, :status
    add_index :reviews, :reviewer_name
    add_index :reviews, :created_at
  end
end