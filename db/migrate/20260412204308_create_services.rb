class CreateServices < ActiveRecord::Migration[8.0]
  def change
    create_table :services do |t|
      t.string  :name,             null: false
      t.text    :description
      t.integer :duration_minutes, null: false
      t.decimal :price,            null: false, precision: 8, scale: 2
      t.boolean :active,           null: false, default: true

      t.timestamps
    end

    add_index :services, :name, unique: true
  end
end