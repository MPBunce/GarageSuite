class RemoveLicensePlates < ActiveRecord::Migration[8.0]
  def change
    remove_column :appointments, :guest_vehicle_license, :string
    remove_column :vehicles, :license_plate, :string
  end
end