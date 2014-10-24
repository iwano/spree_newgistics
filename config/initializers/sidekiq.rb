require 'sidekiq/scheduler'
Sidekiq.schedule = YAML.load_file(File.join(File.dirname(__FILE__),"../sidekiq-schedule.yml")) if Rails.env.production?
