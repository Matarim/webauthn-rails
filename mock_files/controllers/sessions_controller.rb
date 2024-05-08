# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[new create webauthn_authentications]
  before_action :redirect_if_authenticated, only: :new

  def new
    session.delete(:webauthn_authentication)
    session['original_uri'] = sign_in_path
  end

  def create
    if params[:password].blank?
      user = User.find_by(email: params[:email])

      if user.user_settings.last.passwordless && user.credentials.any?
        session[:webauthn_authentication] = { user_id: user.id }
        get_options = WebAuthn::Credential.options_for_get(
          allow: user.credentials.pluck(:external_id),
          user_verification: 'required'
        )

        save_registration('challenge' => get_options.challenge)

        hash = {
          original_url: session['original_uri'],
          callback_url: webauthn_authentications_path(format: :json),
          get_options: get_options
        }

        respond_to do |format|
          format.json { render json: hash }
        end
      else
        redirect_to sign_in_path, status: :unprocessable_entity,
                    alert: "Invalid email or passwordless access is not turned on."
      end
    else
      if (user = User.authenticate_by(authentication_params))
        if user.credentials.any?
          session[:webauthn_authentication] = { user_id: user.id }
          if user.user_settings.last.require_auth
            get_options = WebAuthn::Credential.options_for_get(
              allow: user.credentials.pluck(:external_id),
              user_verification: 'required'
            )

            save_registration('challenge' => get_options.challenge)

            hash = {
              original_url: session['original_uri'],
              callback_url: webauthn_authentications_path(format: :json),
              get_options: get_options
            }

            respond_to do |format|
              format.json { render json: hash }
            end
          else
            sign_in user
          end
        else
          sign_in user
        end
      else
        redirect_to sign_in_path, status: :unprocessable_entity, alert: "Invalid email or password."
      end
    end
  rescue StandardError
    redirect_to sign_in_path, status: :unprocessable_entity, alert: "Invalid email or password."
  end

  def destroy
    sign_out current_user
    redirect_to root_path, notice: "You are no longer signed in."
  end

  def profile
    session['original_uri'] = profile_path
    credentials = current_user.credentials.order(created_at: :desc)

    render :profile, locals: {
      credentials: credentials
    }
  end

  def webauthn_authentications
    webauthn_credential = WebAuthn::Credential.from_get(params)

    user = User.find(session[:webauthn_authentication]['user_id'])
    credential = user.credentials.find_by(external_id: external_id(webauthn_credential).to_s)

    begin
      webauthn_credential.verify(
        saved_challenge,
        public_key: credential.public_key,
        sign_count: credential.sign_count,
        user_verification: true
      )

      credential.update!(sign_count: webauthn_credential.sign_count)

      sign_in(user)
    rescue WebAuthn::Error => e
      render json: "Verification failed: #{e.message}", status: :unprocessable_entity, alert: 'Verification failed!'
    ensure
      session.delete(:current_authentication)
    end
  end

  private

  def authentication_params
    {email: params[:email], password: params[:password]}
  end

  def saved_nickname(nickname)
    session['nickname'] = nickname
  end

  def saved_registration
    session['current_registration']
  end

  def save_registration(v)
    session['current_registration'] = v
  end

  def saved_challenge
    saved_registration['challenge']
  end

  def external_id(webauthn_credential)
    Base64.strict_encode64(webauthn_credential.raw_id)
  end
end
