# frozen_string_literal: true

namespace :demo do
  desc "Queue AI processing job for the most recent submitted submission"
  task queue_ai_job: :environment do
    submission = Submission.where(status: :submitted).order(updated_at: :desc).first

    if submission
      AiSubmissionProcessingJob.perform_later(submission.id)
      puts "Enqueued AI processing for submission ##{submission.id}."
    else
      puts "No submissions in submitted status."
    end
  end

  desc "Queue deadline reminders for tasks due tomorrow"
  task queue_deadline_reminders: :environment do
    target_date = Date.tomorrow
    DeadlineReminderJob.perform_later(target_date)
    puts "Enqueued deadline reminders for #{target_date}."
  end
end
