# frozen_string_literal: true

require "rails_helper"

RSpec.describe DeadlineReminderJob, type: :job do
  let(:teacher) { create(:user, :teacher) }
  let!(:students) do
    Array.new(2) { |i| create(:user, email: "student-#{i}-#{SecureRandom.hex(4)}@example.com") }
  end
  let!(:task_due_tomorrow) { create(:task, due_on: Date.tomorrow) }
  let!(:task_due_later) { create(:task, due_on: Date.current + 5.days) }

  before do
    create(:submission, user: students.first, task: task_due_tomorrow, status: :returned)
    create(:submission, user: students.second, task: task_due_tomorrow, status: :submitted)
  end

  it "creates notifications for students without returned submissions" do
    target_scope = -> {
      Notification.where(kind: :deadline_reminder, user: students.second)
                   .where("payload ->> 'task_id' = ?", task_due_tomorrow.id.to_s)
                   .count
    }

    expect do
      described_class.perform_now(Date.tomorrow)
    end.to change(target_scope, :call).by(1)
  end

  it "does not create reminders for other dates" do
    expect do
      described_class.perform_now(Date.current + 2.days)
    end.not_to change(Notification, :count)
  end
end
