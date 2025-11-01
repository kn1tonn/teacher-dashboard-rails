FactoryBot.define do
  factory :memo do
    association :user
    association :submission
    body { "Remember to emphasise pronunciation drills next session." }
    visibility { :teacher_only }
  end
end
