# db/seeds.rb

# Create roles
customer_role = Role.find_or_create_by!(name: Role::CUSTOMER) do |r|
  r.description = "Standard customer with booking access"
end

admin_role = Role.find_or_create_by!(name: Role::ADMIN) do |r|
  r.description = "Administrator with full system access"
end

# Create a default admin user
admin = User.find_or_create_by!(email: "dnaautosource@gmail.com") do |u|
  u.first_name = "Admin"
  u.last_name  = "User"
  u.password   = "astonmartin123!"
  u.active     = true
end

admin.assign_role(Role::ADMIN)

puts "✅ Roles created: #{Role.pluck(:name).join(', ')}"
puts "✅ Admin user created: #{admin.email}"

# Services
oil_change = Service.find_or_create_by!(name: "Oil Change") do |s|
  s.description       = "Full synthetic oil change and filter replacement"
  s.duration_minutes  = 30
  s.price             = 49.99
end

brake_inspection = Service.find_or_create_by!(name: "Brake Inspection") do |s|
  s.description       = "Full brake system inspection"
  s.duration_minutes  = 45
  s.price             = 29.99
end

tire_rotation = Service.find_or_create_by!(name: "Tire Rotation") do |s|
  s.description       = "Rotate all four tires"
  s.duration_minutes  = 30
  s.price             = 24.99
end

puts "✅ Services created: #{Service.pluck(:name).join(', ')}"

# Sample customer
customer = User.find_or_create_by!(email: "customer@example.com") do |u|
  u.first_name = "John"
  u.last_name  = "Smith"
  u.password   = "password123!"
  u.active     = true
end
customer.assign_role(Role::CUSTOMER)
puts "✅ Customer created: #{customer.email}"

# Sample vehicle
vehicle = Vehicle.find_or_create_by!(license_plate: "ABC123") do |v|
  v.user  = customer
  v.make  = "Toyota"
  v.model = "Camry"
  v.year  = 2020
  v.vin   = "1HGBH41JXMN109186"
end
puts "✅ Vehicle created: #{vehicle.display_name}"

# Sample appointment
appointment = Appointment.find_or_create_by!(
  customer: customer,
  service:  oil_change,
  vehicle:  vehicle
) do |a|
  a.scheduled_at    = 2.days.from_now.change(hour: 10)
  a.status          = :pending
  a.customer_notes  = "Please use full synthetic oil"
end
puts "✅ Appointment created: #{appointment.service.name} - #{appointment.status}"