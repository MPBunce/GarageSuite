class AddTypedValuesToAppSettings < ActiveRecord::Migration[8.0]
  def change
    add_column :app_settings, :value_type, :string, null: false, default: "boolean"
    add_column :app_settings, :value_string, :string
    add_column :app_settings, :value_integer, :integer

    change_column_null :app_settings, :value_boolean, true
  end
end
