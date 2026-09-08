class Tenant < ApplicationRecord
  include Auditable

  has_secure_token :api_key

  validates :domain, presence: true, uniqueness: true
  validates :api_key, presence: true, uniqueness: true
  validates :reply_to, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :brand_color, format: { with: /\A#[0-9a-fA-F]{6}\z/ }, allow_blank: true
end
