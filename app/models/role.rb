class Role < ApplicationRecord
  CUSTOMER = "customer".freeze
  ADMIN    = "admin".freeze
  ALL      = [CUSTOMER, ADMIN].freeze

  has_many :user_roles, dependent: :destroy
  has_many :users, through: :user_roles

  validates :name, presence: true,
                   uniqueness: { case_sensitive: false },
                   inclusion: { in: ALL }

  before_save :downcase_name

  private

  def downcase_name
    self.name = name.downcase
  end
end