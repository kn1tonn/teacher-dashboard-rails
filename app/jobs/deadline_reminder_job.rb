# frozen_string_literal: true

class DeadlineReminderJob < ApplicationJob
  queue_as :default

  def perform(target_date = Date.current)
    tasks = Task.where(active: true, due_on: target_date)

    return if tasks.blank?

    student_ids = User.student.pluck(:id)

    tasks.each do |task|
      student_ids.each do |student_id|
        submission = Submission.where(user_id: student_id, task_id: task.id).order(updated_at: :desc).first
        next if submission&.status == "returned"

        Notification.find_or_create_by!(
          user_id: student_id,
          kind: :deadline_reminder,
          payload: {
            task_id: task.id,
            task_title: task.title,
            due_on: task.due_on
          }
        )
      end
    end
  end
end
