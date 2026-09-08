class CreateTenants < ActiveRecord::Migration[8.0]
  def change
    create_table :tenants do |t|
      t.string :domain, null: false
      t.string :display_name
      t.string :reply_to
      t.string :logo_url
      t.string :brand_color
      t.string :api_key, null: false
      t.string :verified_sending_domain
      t.timestamps
    end

    add_index :tenants, :domain, unique: true
    add_index :tenants, :api_key, unique: true
  end
end