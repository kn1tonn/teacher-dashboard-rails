# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Memos", type: :request do
  describe "POST /memos" do
    let(:student) { create(:user, email: "memo-student-#{SecureRandom.hex(4)}@example.com") }
    let(:task) { create(:task) }
    let(:submission) { create(:submission, user: student, task: task) }

    before do
      submission
      sign_in student, scope: :user
    end

    it "creates a personal memo for the current student" do
      expect do
        post memos_path, params: { memo: { submission_id: submission.id, body: "Focus on pronunciation practice." } }
      end.to change(Memo, :count).by(1)

      expect(response).to redirect_to(dashboard_path(anchor: "feedback-history"))
      memo = Memo.last
      expect(memo.visibility).to eq("student_self")
      expect(memo.user).to eq(student)
    end

    it "rejects blank memo bodies" do
      post memos_path, params: { memo: { submission_id: submission.id, body: "" } }

      expect(response).to redirect_to(dashboard_path(anchor: "feedback-history"))
      expect(flash[:alert]).to include("Body can't be blank")
    end

    it "prevents access to other students' submissions" do
      other_student = create(:user, email: "memo-other-#{SecureRandom.hex(4)}@example.com")
      other_submission = create(:submission, user: other_student, task: task)

      expect do
        post memos_path, params: { memo: { submission_id: other_submission.id, body: "Should not work" } }
      end.not_to change(Memo, :count)

      expect(response).to have_http_status(:not_found)
    end
  end
end
