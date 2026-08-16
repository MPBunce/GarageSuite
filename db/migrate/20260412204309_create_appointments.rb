class CreateAppointments < ActiveRecord::Migration[8.0]
  def change
    create_table :appointments do |t|
      # Two references to users table — customer and admin
      t.bigint :customer_id,       null: false
      t.bigint :assigned_admin_id

      t.references :vehicle, null: false, foreign_key: true
      t.references :service, null: false, foreign_key: true

      t.datetime :scheduled_at,  null: false
      t.integer  :status,        null: false, default: 0
      t.text     :customer_notes
      t.text     :admin_notes

      t.timestamps
    end

    # Manual foreign keys for the named user references
    add_foreign_key :appointments, :users, column: :customer_id
    add_foreign_key :appointments, :users, column: :assigned_admin_id

    # Indexes for fast querying
    add_index :appointments, :customer_id
    add_index :appointments, :assigned_admin_id
    add_index :appointments, :status
    add_index :appointments, :scheduled_at
  end
end
