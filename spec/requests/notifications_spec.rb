# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Notifications", type: :request do
  describe "GET /notifications" do
    it "redirects unauthenticated users" do
      get notifications_path

      expect(response).to redirect_to(new_user_session_path)
    end

    it "renders notifications for signed-in user" do
      user = create(:user, email: "notifications-user-#{SecureRandom.hex(4)}@example.com")
      create(:notification, user: user, kind: :status_changed, payload: { task_title: "Diary", status: :submitted })

      sign_in user

      get notifications_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Submission status updated")
      expect(response.body).to include("Diary")
    end
  end

  describe "PATCH /notifications/:id" do
    it "marks notification as read" do
      user = create(:user, email: "notifications-mark-#{SecureRandom.hex(4)}@example.com")
      notification = create(:notification, user: user, read_at: nil)

      sign_in user

      patch notification_path(notification)

      expect(response).to redirect_to(notifications_path)
      expect(notification.reload.read_at).to be_present
    end
  end
end
