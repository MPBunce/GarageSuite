class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles

  has_many :vehicles,             dependent: :destroy
  has_many :appointments,         foreign_key: "customer_id",
                                  dependent: :destroy
  has_many :managed_appointments, class_name: "Appointment",
                                  foreign_key: "assigned_admin_id",
                                  dependent: :nullify

  validates :first_name, presence: true
  validates :last_name,  presence: true
  validates :phone_number, format: { with: /\A\+?[\d\s\-().]{7,20}\z/ },
                           allow_blank: true

  before_save :downcase_email

  def assign_role(role_name)
    role = Role.find_by!(name: role_name.to_s.downcase)
    roles << role unless has_role?(role_name)
  end

  def remove_role(role_name)
    roles.delete(Role.find_by(name: role_name.to_s.downcase))
  end

  def has_role?(role_name)
    roles.exists?(name: role_name.to_s.downcase)
  end

  def admin?
    has_role?(Role::ADMIN)
  end

  def customer?
    has_role?(Role::CUSTOMER)
  end

  scope :active,    -> { where(active: true) }
  scope :admins,    -> { joins(:roles).where(roles: { name: Role::ADMIN }) }
  scope :customers, -> { joins(:roles).where(roles: { name: Role::CUSTOMER }) }

  def full_name
    "#{first_name} #{last_name}"
  end

  private

  def downcase_email
    self.email = email.downcase
  end
end
