FactoryBot.define do
  factory :notification do
    association :user
    kind { :status_changed }
    payload { { message: "Submission status updated" } }
    read_at { nil }
  end
end
