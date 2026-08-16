class AddGuestFieldsToAppointments < ActiveRecord::Migration[8.0]
  def change
    # Make customer_id optional (guests won't have an account)
    change_column_null :appointments, :customer_id, true

    # Make vehicle_id optional (guests enter vehicle inline)
    change_column_null :appointments, :vehicle_id, true

    # Guest contact details
    add_column :appointments, :guest_name,  :string
    add_column :appointments, :guest_email, :string
    add_column :appointments, :guest_phone, :string

    # Guest vehicle details
    add_column :appointments, :guest_vehicle_make,    :string
    add_column :appointments, :guest_vehicle_model,   :string
    add_column :appointments, :guest_vehicle_year,    :integer
    add_column :appointments, :guest_vehicle_license, :string

    # Token so guests can look up their appointment without an account
    add_column :appointments, :guest_token, :string

    add_index :appointments, :guest_email
    add_index :appointments, :guest_token, unique: true
  end
end
