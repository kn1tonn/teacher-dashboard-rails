class Task < ApplicationRecord
  enum :task_type, { diary: 0, shadowing: 1 }

  has_many :submissions, dependent: :destroy

  validates :title, presence: true
  validates :task_type, presence: true
end
