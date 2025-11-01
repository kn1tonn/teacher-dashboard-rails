# frozen_string_literal: true

module NotificationsHelper
  def notification_title(notification)
    case notification.kind
    when "deadline_reminder"
      "Upcoming deadline"
    when "feedback_published"
      "Feedback published"
    when "status_changed"
      "Submission status updated"
    else
      "Notification"
    end
  end

  def notification_message(notification)
    payload = notification.payload.symbolize_keys

    case notification.kind
    when "deadline_reminder"
      "#{payload[:task_title]} is due on #{payload[:due_on]}."
    when "feedback_published"
      "Your feedback for #{payload[:task_title]} is available."
    when "status_changed"
      "#{payload[:task_title]} is now #{payload[:status].to_s.humanize}."
    else
      payload[:message] || ""
    end
  end
end
