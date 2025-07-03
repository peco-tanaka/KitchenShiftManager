# frozen_string_literal: true

class DeviseCreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      ## Database authenticatable
      t.integer :employee_number,   null: false, comment: '社員番号（4桁）'
      t.string  :encrypted_password, null: false, default: ""

      ## Recoverable (本システムでは無効化)
      # t.string   :reset_password_token
      # t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable (本システムでは無効化)
      # t.integer  :sign_in_count, default: 0, null: false
      # t.datetime :current_sign_in_at
      # t.datetime :last_sign_in_at
      # t.string   :current_sign_in_ip
      # t.string   :last_sign_in_ip

      ## Confirmable (本システムでは無効化)
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable (本システムでは無効化)
      # t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at

      ## 飲食店勤怠管理システム用カラム
      t.integer :role,           null: false, default: 0, comment: 'ロール: 0=employee, 1=manager'
      t.integer :hourly_wage,    null: false, comment: '時給（円）'
      t.date    :hired_on,       null: false, comment: '入社日'
      t.date    :terminated_on,  null: true,  comment: '退職日'

      t.timestamps null: false
    end

    ## 頻繁に使用するカラムのみインデックスをつける
    add_index :users, :employee_number,      unique: true
    add_index :users, :role

    # add_index :users, :reset_password_token, unique: true
    # add_index :users, :confirmation_token,   unique: true
    # add_index :users, :unlock_token,         unique: true
  end
end
