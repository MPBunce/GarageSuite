class Service < ApplicationRecord
  has_many :appointments, dependent: :restrict_with_error

  validates :name,             presence: true, uniqueness: true
  validates :duration_minutes, presence: true,
                               numericality: {
                                 only_integer: true,
                                 greater_than: 0
                               }
  validates :price,            numericality: {
                                 greater_than_or_equal_to: 0
                               },
                               allow_blank: true

  scope :active, -> { where(active: true) }

  def formatted_price
    return "Price available on request" if price.blank? || price.to_d <= 0

    "$#{'%.2f' % price}"
  end

  def formatted_duration
    if duration_minutes < 60
      "#{duration_minutes} mins"
    else
      hours = duration_minutes / 60
      mins  = duration_minutes % 60
      mins > 0 ? "#{hours}hr #{mins}mins" : "#{hours}hr"
    end
  end
end