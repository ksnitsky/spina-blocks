# frozen_string_literal: true

Rails.application.configure do
  config.cache_classes = true
  config.eager_load = false

  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    'Cache-Control' => 'public, max-age=3600'
  }

  config.consider_all_requests_local = true
  config.action_controller.perform_caching = false

  config.action_dispatch.show_exceptions = :none
  config.action_controller.allow_forgery_protection = false

  config.active_support.deprecation = :stderr
  config.active_support.disallowed_deprecations_treatment = :raise

  config.active_storage.service = :test

  config.action_mailer.delivery_method = :test
end
