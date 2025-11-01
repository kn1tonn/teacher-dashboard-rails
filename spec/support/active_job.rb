# frozen_string_literal: true

RSpec.configure do |config|
  config.include ActiveJob::TestHelper, type: :job
  config.around(:each, type: :job) do |example|
    perform_enqueued_jobs { example.run }
  end
end
