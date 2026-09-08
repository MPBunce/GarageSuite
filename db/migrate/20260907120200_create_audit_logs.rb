class CreateAuditLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :audit_logs do |t|
      t.references :actor, foreign_key: { to_table: :users }, null: true
      t.references :auditable, polymorphic: true, null: false
      t.string :action, null: false
      t.jsonb :changeset, null: false, default: {}
      t.datetime :created_at, null: false
    end

    add_index :audit_logs, [ :auditable_type, :auditable_id, :created_at ]
  end
end