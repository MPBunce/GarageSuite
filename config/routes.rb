Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions:      "users/sessions"
  }

  # Public
  root "pages#home"

  # Public booking flow
  get  "/booking",         to: "booking#index",   as: :booking
  post "/booking",         to: "booking#update",  as: :booking_update
  get  "/booking/confirm", to: "booking#confirm", as: :booking_confirm
  post "/booking/confirm", to: "booking#create",  as: :booking_create

  # Guest appointment lookup
  get "/appointments/lookup",        to: "booking#lookup", as: :appointment_lookup
  get "/appointments/lookup/result", to: "booking#result", as: :appointment_result

  # Customer routes
  scope module: "customers" do
    get    "/dashboard",          to: "dashboard#index",    as: :customer_dashboard
    get    "/appointments",       to: "appointments#index", as: :customer_appointments
    get    "/appointments/:id",   to: "appointments#show",  as: :customer_appointment
    delete "/appointments/:id",   to: "appointments#destroy"
    get    "/vehicles",           to: "vehicles#index",     as: :customer_vehicles
    get    "/vehicles/new",       to: "vehicles#new",       as: :new_customer_vehicle
    post   "/vehicles",           to: "vehicles#create"
    get    "/vehicles/:id",       to: "vehicles#show",      as: :customer_vehicle
    delete "/vehicles/:id",       to: "vehicles#destroy"
  end

  # Admin routes
  namespace :admin do
    get "/dashboard", to: "dashboard#index"
    resources :appointments, only: [:index, :show, :update, :destroy]
    resources :services
    resources :users, only: [:index, :show, :update, :destroy]
  end
end