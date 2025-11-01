# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Submissions", type: :request do
  describe "POST /submissions" do
    let(:student) { create(:user, email: "submission-student-#{SecureRandom.hex(4)}@example.com") }
    let(:task) { create(:task) }

    before { sign_in student, scope: :user }

    it "creates a submission and marks it as submitted" do
      expect do
        post submissions_path, params: { submission: { task_id: task.id, content: "My weekly reflection" } }
      end.to change(Submission, :count).by(1)

      expect(response).to redirect_to(dashboard_path)
      submission = Submission.last
      expect(submission.status).to eq("submitted")
      expect(submission.submitted_at).to be_present
      expect(submission.content).to eq("My weekly reflection")
    end

    it "rejects submissions without content or URL" do
      post submissions_path, params: { submission: { task_id: task.id, content: "", content_url: "" } }

      expect(response).to redirect_to(dashboard_path)
      expect(flash[:alert]).to include("Either content or content URL must be provided")
    end

    it "prevents teachers from submitting" do
      sign_out student
      teacher = create(:user, :teacher, email: "teacher-submissions-#{SecureRandom.hex(4)}@example.com")
      sign_in teacher, scope: :user

      expect do
        post submissions_path, params: { submission: { task_id: task.id, content: "Teacher attempt" } }
      end.not_to change(Submission, :count)

      expect(response).to redirect_to(dashboard_path)
      expect(flash[:alert]).to eq("Only students can submit assignments.")
    end
  end
end
