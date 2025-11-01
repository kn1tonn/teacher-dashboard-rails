# frozen_string_literal: true

module Teacher
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_teacher!

    private

    def ensure_teacher!
      return if current_user.teacher?

      redirect_to dashboard_path, alert: "You are not authorised to access teacher tools."
    end
  end
end
