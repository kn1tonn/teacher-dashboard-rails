# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: "Google") if is_navigational_format?
    else
      flash[:alert] = I18n.t(
        "devise.omniauth_callbacks.failure",
        kind: "Google",
        reason: "account could not be created"
      )
      redirect_to new_user_session_path
    end
  rescue StandardError => e
    Rails.logger.error("[OmniAuth] Google sign-in failed: #{e.class}: #{e.message}")
    flash[:alert] = I18n.t(
      "devise.omniauth_callbacks.failure",
      kind: "Google",
      reason: "unexpected error"
    )
    redirect_to new_user_session_path
  end

  def failure
    flash[:alert] = I18n.t(
      "devise.omniauth_callbacks.failure",
      kind: "Google",
      reason: "authentication error"
    )
    redirect_to new_user_session_path
  end
end
