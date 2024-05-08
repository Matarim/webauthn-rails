Rails.application.routes.draw do
  mount WebauthnRails::Engine => "/webauthn-rails"
end
