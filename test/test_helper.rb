ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module SettingsTestHelper
  def set_setting(key, type, value)
    setting = AppSetting.find_or_initialize_by(key: key.to_s)
    setting.assign_typed_value(value, type.to_sym)
    setting.save!
    setting
  end
end

module RolesTestHelper
  def role(name)
    Role.find_or_create_by!(name: name)
  end

  def create_user(attributes = {})
    User.create!({
      email: "user-#{SecureRandom.hex(4)}@example.com",
      password: "password123",
      first_name: "Test",
      last_name: "User"
    }.merge(attributes))
  end

  def create_admin(attributes = {})
    create_user(attributes).tap { |user| user.assign_role(Role::ADMIN) }
  end

  def create_customer(attributes = {})
    create_user(attributes).tap { |user| user.assign_role(Role::CUSTOMER) }
  end
end

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    include SettingsTestHelper
    include RolesTestHelper
  end
end
