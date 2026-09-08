module Auditable
  extend ActiveSupport::Concern

  included do
    has_many :audit_logs, as: :auditable, dependent: :destroy

    after_create_commit :audit_create
    after_update_commit :audit_update
    after_destroy_commit :audit_destroy
  end

  private

  def audit_create
    write_audit_log("create", attributes.except("created_at", "updated_at", "encrypted_password", "reset_password_token"))
  end

  def audit_update
    changeset = saved_changes.except("updated_at", "encrypted_password", "reset_password_token")
    write_audit_log("update", changeset) if changeset.present?
  end

  def audit_destroy
    write_audit_log("destroy", {})
  end

  def write_audit_log(action, changeset)
    AuditLog.create!(actor: Current.actor, auditable: self, action: action, changeset: changeset)
  end
end