FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "Password1!" }
    role { :student }

    trait :teacher do
      role { :teacher }
    end
  end
end
