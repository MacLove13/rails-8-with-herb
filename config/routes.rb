Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token

  # Registration
  get "register", to: "registrations#new", as: :register
  post "register", to: "registrations#create"

  # Profile
  get "profile", to: "profile#show", as: :profile

  # WebAuthn credentials (passkey registration)
  resources :webauthn_credentials, only: %i[index create destroy] do
    collection do
      post :new_registration_options
    end
  end

  # WebAuthn authentication (passkey login)
  post "webauthn_authentications/new_authentication_options",
       to: "webauthn_authentications#new_authentication_options",
       as: :new_webauthn_authentication_options
  post "webauthn_authentications",
       to: "webauthn_authentications#create",
       as: :webauthn_authentication

  # Mission Control Jobs dashboard restricted to admin users
  constraints AdminConstraint.new do
    mount MissionControl::Jobs::Engine, at: "/jobs"
    mount Audits1984::Engine, at: "/console"
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"
end
