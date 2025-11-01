# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Dashboards", type: :request do
  describe "GET /" do
    it "redirects guests to the sign in page" do
      get root_path

      expect(response).to redirect_to(new_user_session_path)
    end

    it "renders the student dashboard for student users" do
      user = create(:user, email: "dashboard-student-#{SecureRandom.hex(4)}@example.com")
      sign_in user

      get root_path

      expect(response.body).to include("This Week&#39;s Tasks")
    end

    it "renders the teacher dashboard for teacher users" do
      teacher = create(:user, :teacher, email: "dashboard-teacher-#{SecureRandom.hex(4)}@example.com")
      sign_in teacher

      get root_path

      expect(response.body).to include("Teacher Dashboard")
    end
  end
end
