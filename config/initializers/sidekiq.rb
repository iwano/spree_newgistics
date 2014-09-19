require 'sidekiq/scheduler'
Sidekiq.schedule = YAML.load_file(File.expand_path("../../../config/sidekiq-schedule.yml",__FILE__))
