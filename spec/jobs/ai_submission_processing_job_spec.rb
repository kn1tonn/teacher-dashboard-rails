# frozen_string_literal: true

require "rails_helper"

RSpec.describe AiSubmissionProcessingJob, type: :job do
  let(:user) { create(:user, email: "ai-job-#{SecureRandom.hex(4)}@example.com") }
  let(:task) { create(:task) }
  let(:submission) do
    create(:submission,
           user: user,
           task: task,
           status: :submitted,
           ai_score: nil,
           ai_summary: nil)
  end

  it "transitions a submitted submission to ai_checked" do
    described_class.perform_now(submission.id)

    submission.reload
    expect(submission.status).to eq("ai_checked")
    expect(submission.ai_score).to be_present
    expect(submission.ai_summary).to be_present
  end

  it "ignores submissions that are not in submitted status" do
    submission.update!(status: :ai_checked)

    expect do
      described_class.perform_now(submission.id)
    end.not_to change { submission.reload.status }
  end
end
