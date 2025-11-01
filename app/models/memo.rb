class Memo < ApplicationRecord
  enum :visibility, { teacher_only: 0, student_self: 1 }

  belongs_to :user
  belongs_to :submission, optional: true

  validates :body, presence: true
  validates :visibility, presence: true
end
