class AddEmailStatusAndAccountTypeToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :email_valid, :boolean, default: true, null: false
    add_column :users, :email_status, :string
    add_column :users, :account_type, :string, default: "standard", null: false
    add_index :users, :account_type
    add_index :users, :email_status
  end
end
