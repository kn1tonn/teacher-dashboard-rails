class Submission < ApplicationRecord
  enum :status, {
    not_submitted: 0,
    submitted: 1,
    ai_checking: 2,
    ai_checked: 3,
    teacher_reviewed: 4,
    returned: 5
  }

  belongs_to :user
  belongs_to :task

  has_one :feedback, dependent: :destroy
  has_many :attachments, as: :attachable, dependent: :destroy
  has_many :memos, dependent: :destroy

  validates :status, presence: true
  validates :user, presence: true
  validates :task, presence: true
  validate :content_or_content_url_present

  ALLOWED_TRANSITIONS = {
    "not_submitted" => %w[submitted],
    "submitted" => %w[ai_checking submitted],
    "ai_checking" => %w[ai_checked],
    "ai_checked" => %w[teacher_reviewed],
    "teacher_reviewed" => %w[returned],
    "returned" => []
  }.freeze

  def allowed_transition?(target_status)
    target_status = target_status.to_s
    return true if target_status == status

    ALLOWED_TRANSITIONS.fetch(status, []).include?(target_status)
  end

  private

  def content_or_content_url_present
    return if content.present? || content_url.present?

    errors.add(:base, "Either content or content URL must be provided")
  end
end
