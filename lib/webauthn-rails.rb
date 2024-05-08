require "webauthn_rails/version"
require "webauthn_rails/engine"
require "webauthn"

module WebauthnRails
  module Controllers
    autoload :Credentials,   'devise/controllers/credentials'
  end
  # Your code goes here...
end
