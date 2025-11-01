class Feedback < ApplicationRecord
  belongs_to :submission
  has_many :attachments, as: :attachable, dependent: :destroy

  has_rich_text :teacher_comment

  delegate :user, to: :submission

  before_save :sync_plain_comment

  private

  def sync_plain_comment
    self[:teacher_comment] = teacher_comment.body.to_plain_text if teacher_comment.present?
  end
end
