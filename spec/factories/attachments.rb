FactoryBot.define do
  factory :attachment do
    association :attachable, factory: :submission
    file { "sample.txt" }

    after(:build) do |attachment|
      next if attachment.asset.attached?

      attachment.asset.attach(
        io: StringIO.new("Sample attachment content"),
        filename: attachment.file,
        content_type: "text/plain"
      )
    end
  end
end
