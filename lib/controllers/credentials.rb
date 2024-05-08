module WebauthnRails
  module Controllers
    # A module that handles adding functionality to the controller
    # to provide better handling of credentials with webauthn
    module Credentials
      def self.encode_id(raw_id)
        Base64.strict_encode64(raw_id)
      end

      def build_credentials(user, options)
        required_keys = [:raw_id, :public_key, :nickname, :sign_count]
        missing_keys = required_keys - options.keys

        unless missing_keys.empty?
          raise ArgumentError.new("Missing required options: #{missing_keys.join(', ')}")
        end

        user.credentials.build(
          external_id: encode_id(options[:raw_id]),
          public_key: options[:public_key],
          nickname: options[:nickname],
          sign_count: options[:sign_count]
        )
      end

      def create_challenge(user, options)
        ::WebAuthn::Credential.options_for_create(
          user: {
            id: user.webauthn_id,
            display_name: options[:username],
            name: options[:username]
          },
          authenticator_selection: {
            # Webauthn user verification options: 'required', 'preferred', 'discouraged'
            user_verification: options[:verification],
          },
        )
      end

      def get_challenge(user, options)
        WebAuthn::Credential.options_for_get(
          allow: user.credentials.pluck(:external_id),
          # Webauthn user verification options: 'required', 'preferred', 'discouraged'
          user_verification: options[:verification]
        )
      end

      private

      def save_registration(challenge, nickname)
        session['current_registration'] = { challenge: challenge, nickname: nickname }
      end

      def saved_registration
        session['current_registration']
      end

      def saved_challenge
        saved_registration['challenge']
      end
    end
  end
end