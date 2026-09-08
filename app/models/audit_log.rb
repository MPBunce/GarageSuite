class AuditLog < ApplicationRecord
  belongs_to :actor, class_name: "User", optional: true
  belongs_to :auditable, polymorphic: true

  validates :action, presence: true, inclusion: { in: %w[create update destroy] }
end