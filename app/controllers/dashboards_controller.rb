# frozen_string_literal: true

class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def show
    @dashboard_role = current_user.teacher? ? :teacher : :student
  end
end
