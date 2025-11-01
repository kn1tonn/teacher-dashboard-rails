FactoryBot.define do
  factory :task do
    title { "Weekly Reflection" }
    description { "Write about your study highlights this week." }
    task_type { :diary }
    due_on { 1.week.from_now.to_date }
    active { true }
  end
end
