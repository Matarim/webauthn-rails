module Webauthn
  module Rails
    class Engine < ::Rails::Engine
      isolate_namespace WebauthnRails
    end
  end
end
