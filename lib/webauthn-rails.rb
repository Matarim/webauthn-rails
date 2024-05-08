require "webauthn_rails/version"
require "webauthn_rails/engine"
require "webauthn"

module WebauthnRails
  module Controllers
    autoload :Credentials,   'devise/controllers/credentials'
  end

  # Keys used when authenticating a user.
  mattr_accessor :auth_key
  @@auth_key = [:email]

  # Your code goes here...
end
