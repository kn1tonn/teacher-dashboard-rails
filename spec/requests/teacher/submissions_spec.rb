# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Teacher::Submissions", type: :request do
  let(:teacher) { create(:user, :teacher, email: "teacher-api-#{SecureRandom.hex(4)}@example.com") }
  let(:student) { create(:user, email: "student-api-#{SecureRandom.hex(4)}@example.com") }
  let(:task) { create(:task) }
  let(:submission) { create(:submission, user: student, task: task, status: :ai_checked) }

  before do
    submission
    sign_in teacher, scope: :user
  end

  describe "PATCH /teacher/submissions/:id" do
    it "updates status when transition allowed" do
      expect do
        patch teacher_submission_path(submission), params: { submission: { status: :teacher_reviewed } }
      end.to change(Notification, :count).by(1)

      expect(response).to redirect_to(teacher_submission_path(submission))
      expect(submission.reload.status).to eq("teacher_reviewed")
    end

    it "rejects invalid transitions" do
      patch teacher_submission_path(submission), params: { submission: { status: :not_submitted } }

      expect(response).to redirect_to(teacher_submission_path(submission))
      expect(flash[:alert]).to eq("Invalid status transition.")
      expect(submission.reload.status).to eq("ai_checked")
    end
  end

  describe "POST /teacher/submissions/:submission_id/feedback" do
    it "saves feedback, publishes, and notifies the student" do
      expect do
        post teacher_submission_feedback_path(submission), params: { feedback: { teacher_comment: "Great work!", published: "1" } }
      end.to change(Notification, :count).by(1)

      expect(response).to redirect_to(teacher_submission_path(submission))
      feedback = submission.reload.feedback
      expect(feedback.teacher_comment.body.to_plain_text.strip).to eq("Great work!")
      expect(feedback.published_at).to be_present
      expect(submission.status).to eq("returned")
    end
  end
end
