# frozen_string_literal: true

class AiSubmissionProcessingJob < ApplicationJob
  queue_as :ai

  def perform(submission_id)
    submission = Submission.find(submission_id)

    return unless submission.status == "submitted"

    submission.update!(status: :ai_checking)

    # Simulate calling an external AI service
    submission.update!(
      status: :ai_checked,
      ai_score: submission.ai_score || rand(65..95),
      ai_summary: submission.ai_summary.presence || "Automated review complete. Ready for teacher feedback."
    )
  end
end
