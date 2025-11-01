class Notification < ApplicationRecord
  enum :kind, {
    deadline_reminder: 0,
    feedback_published: 1,
    status_changed: 2
  }

  belongs_to :user

  validates :kind, presence: true
  validates :payload, presence: true

  scope :unread, -> { where(read_at: nil) }
end
