class CreateKylasEngineUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :kylas_engine_users do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ''
      t.string :encrypted_password, null: false, default: ''

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email # Only if using reconfirmable

      t.timestamps null: false

      t.string :name
      t.boolean :is_tenant, default: false
      t.string :kylas_access_token
      t.string :kylas_refresh_token
      t.datetime :kylas_access_token_expires_at, precision: 6
      t.string :kylas_user_id
      t.boolean :active, default: false
    end

    add_index :kylas_engine_users, :email,                unique: true
    add_index :kylas_engine_users, :reset_password_token, unique: true
    add_index :kylas_engine_users, :confirmation_token,   unique: true
  end
end
