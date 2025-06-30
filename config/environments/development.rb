Rails.application.configure do
  config.cache_classes = false
  config.eager_load = false
  config.consider_all_requests_local = true
  config.cache_store = :null_store
  config.active_record.verbose_query_logs = true
  config.log_level = :debug
  config.log_tags = [ :request_id ]
  config.action_controller.perform_caching = false
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.perform_caching = false
  config.active_record.migration_error = :page_load
  config.active_record.dump_schema_after_migration = false
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker
end