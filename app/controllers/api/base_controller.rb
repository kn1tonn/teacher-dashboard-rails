# frozen_string_literal: true

module Api
  class BaseController < ActionController::API
    include ActionController::HttpAuthentication::Token::ControllerMethods

    before_action :authenticate_api_user!

    private

    def authenticate_api_user!
      authenticate_or_request_with_http_token do |token, _options|
        ActiveSupport::SecurityUtils.secure_compare(token, expected_token)
      end
    end

    def expected_token
      ENV.fetch("API_TOKEN", "development-token")
    end
  end
end
