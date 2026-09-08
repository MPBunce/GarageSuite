class Vehicle < ApplicationRecord
  include Auditable

  belongs_to :user

  has_many :appointments, dependent: :restrict_with_error

  validates :make,          presence: true
  validates :model,         presence: true
  validates :year,          presence: true,
                            numericality: {
                              only_integer: true,
                              greater_than: 1900,
                              less_than_or_equal_to: Date.current.year + 1
                            }
  validates :vin,           uniqueness: true, allow_blank: true

  scope :active, -> { where(active: true) }

  def display_name
    "#{year} #{make} #{model}"
  end
end
