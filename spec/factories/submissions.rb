FactoryBot.define do
  factory :submission do
    association :user
    association :task
    status { :submitted }
    content { "Sample submission content" }
    content_url { nil }
    submitted_at { Time.current }
    ai_score { 80 }
    ai_summary { "Solid grammar and vocabulary." }
  end
end
