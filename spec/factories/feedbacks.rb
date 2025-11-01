FactoryBot.define do
  factory :feedback do
    association :submission
    teacher_comment { "Thoughtful reflection with actionable next steps." }
    published_at { Time.current }
  end
end
