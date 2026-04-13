class CreateVehicles < ActiveRecord::Migration[8.0]
  def change
    create_table :vehicles do |t|
      t.references :user, null: false, foreign_key: true
      t.string  :make,          null: false
      t.string  :model,         null: false
      t.integer :year,          null: false
      t.string  :license_plate, null: false
      t.string  :vin
      t.boolean :active,        null: false, default: true

      t.timestamps
    end

    add_index :vehicles, :license_plate, unique: true
    add_index :vehicles, :vin,           unique: true, where: "vin IS NOT NULL"
  end
end