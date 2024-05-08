# frozen_string_literal: true

module Authentication
  extend ActiveSupport::Concern

  included do
    helper_method :current_user, :user_signed_in?
  end

  def sign_in(user)
    reset_session
    Current.user = user

    if user.user_settings.last.accept_cookies
      cookies.encrypted[:user_id] = cookie_configuration(user)
    else
      session['user_id'] = user.id
    end

    session['original_uri'] = sign_in_path

    respond_to do |format|
      format.html { redirect_to dashboard_path, notice: "You are now signed in." }
      format.json { render json: { status: "ok" }, status: :ok }
    end
  end

  def sign_out(user)
    Current.user = nil
    reset_session
    cookies.delete(:user_id)
  end

  def authenticate_user!
    if current_user.blank?
      redirect_to sign_in_path, alert: "You need to sign in first."
    end
  end

  def authenticate_admin!
    unless current_user.admin? && user_signed_in?
      redirect_to dashboard_path, alert: 'Access Denied'
    end
  end

  def redirect_if_authenticated
    redirect_to dashboard_path if user_signed_in?
  end

  private

  def cookie_configuration(user)
    secure = Rails.env.production? ? true : false

    {
      expires: 3.days.from_now,
      httponly: secure,
      value: user.id,
      secure: secure
    }
  end

  def current_user
    Current.user ||= authenticate_user_from_session
  end

  def user_signed_in?
    current_user.present?
  end

  def authenticate_user_from_session
    user_id = cookies.encrypted[:user_id] || session['user_id']
    User.find_by(id: user_id)
  end
end