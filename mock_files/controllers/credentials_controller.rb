class CredentialsController < ApplicationController
  before_action :authenticate_user!, except: %i[create callback]

  def index
    credentials = current_user.credentials.order(created_at: :desc)
    session['original_uri'] = credentials_path

    render :index, locals: {
      credentials: credentials
    }
  end

  def new; end

  def create
    user = current_user
    user.update(webauthn_id: WebAuthn.generate_user_id) unless current_user.webauthn_id

    create_options = WebAuthn::Credential.options_for_create(
      user: {
        id: current_user.webauthn_id,
        display_name: current_user.email, # we have only the email
        name: current_user.email # we have only the email
      },
      authenticator_selection: {
        user_verification: 'required',
      },
    )

    if user.present?
      save_registration('challenge' => create_options.challenge, 'nickname' => params[:credential][:nickname])

      hash = {
        # TODO: change this to the address the request came from
        original_url: session['original_uri'],
        callback_url: callback_credentials_path(format: :json),
        create_options: create_options
      }

      respond_to do |format|
        format.json { render json: hash }
      end
    else
      respond_to do |format|
        format.json { render json: { errors: user.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  # POST   /registration/callback(.:format)
  def callback
    webauthn_credential = WebAuthn::Credential.from_create(params)

    begin
      webauthn_credential.verify(saved_challenge)

      credential = current_user.credentials.build(
        external_id: Base64.strict_encode64(webauthn_credential.raw_id),
        public_key: webauthn_credential.public_key,
        nickname: session['current_registration']['nickname'] || "Security Key - #{webauthn_credential.public_key[0..5]}",
        sign_count: webauthn_credential.sign_count
      )

      if credential.save
        render :create, locals: {credential: credential}, status: :created
      else
        render turbo_stream: turbo_stream.update("webauthn_credential_error", "<p class=\"text-danger\">Couldn't add your Security Key</p>")
      end
    rescue WebAuthn::Error => e
      render turbo_stream: turbo_stream.update("webauthn_credential_error", "<p class=\"text-danger\">Verification failed: #{e.message}</p>")
    rescue Exception => e
      render turbo_stream: turbo_stream.update("webauthn_credential_error", "<p class=\"text-danger\">Exception Thrown: #{e.message}</p>")
    ensure
      session.delete(:current_registration)
    end
  end

  def destroy
    credential = current_user.credentials.find(params[:id])
    credential.destroy

    render turbo_stream: turbo_stream.remove(credential)
  end

  private

  def registration_params
    params.require(:credentials).permit(:nickname, :email)
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
end
