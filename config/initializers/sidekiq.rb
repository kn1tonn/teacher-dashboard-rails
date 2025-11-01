# frozen_string_literal: true

Rails.application.config.active_job.queue_adapter = :sidekiq if Rails.env.development?

Sidekiq.configure_server do |config|
  config.logger.level = Logger::INFO
end

Sidekiq.configure_client do |_config|
end
