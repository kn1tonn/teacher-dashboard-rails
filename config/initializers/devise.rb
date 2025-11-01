# frozen_string_literal: true

# Assuming you have not yet modified this file, each configuration option below
# is set to its default value. Note that some are commented out while others
# are not: uncommented lines are intended to protect your configuration from
# breaking changes in upgrades (i.e., in the event that future versions of
# Devise change the default values for those options).
#
# Use this hook to configure devise mailer, warden hooks and so forth.
# Many of these configuration options can be set straight in your model.
require "omniauth/rails_csrf_protection"

Devise.setup do |config|
  config.mailer_sender = ENV.fetch("DEFAULT_MAILER_SENDER", "no-reply@example.com")
  require "devise/orm/active_record"
  config.case_insensitive_keys = [ :email ]
  config.strip_whitespace_keys = [ :email ]
  config.skip_session_storage = [ :http_auth ]
  config.stretches = Rails.env.test? ? 1 : 12
  config.reconfirmable = true
  config.expire_all_remember_me_on_sign_out = true
  config.password_length = 6..128
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/
  config.reset_password_within = 6.hours
  config.sign_out_via = :delete
  OmniAuth.config.allowed_request_methods = [ :post ]

  google_client_id = ENV["GOOGLE_CLIENT_ID"] || Rails.application.credentials.dig(:google, :client_id)
  google_client_secret = ENV["GOOGLE_CLIENT_SECRET"] || Rails.application.credentials.dig(:google, :client_secret)

  unless google_client_id.present? && google_client_secret.present?
    message = "[Devise] GOOGLE_CLIENT_ID / GOOGLE_CLIENT_SECRET are not configured. Using placeholder credentials."
    if Rails.env.production?
      raise message
    else
      Rails.logger.warn(message)
      google_client_id ||= "dummy-client-id"
      google_client_secret ||= "dummy-client-secret"
    end
  end

  config.omniauth :google_oauth2,
                  google_client_id,
                  google_client_secret,
                  scope: "email,profile",
                  access_type: "offline",
                  prompt: "consent"
  config.responder.error_status = :unprocessable_entity
  config.responder.redirect_status = :see_other
end
