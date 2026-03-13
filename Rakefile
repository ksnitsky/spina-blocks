# frozen_string_literal: true

APP_RAKEFILE = File.expand_path("spec/dummy/Rakefile", __dir__)
load "rails/tasks/engine.rake"

# The engine.rake mechanism auto-appends db/migrate/ from ENGINE_ROOT to the
# migration paths. This causes ordering issues because engine migrations use
# sequential versions (1, 2, 3, 4) that sort before the timestamped copies in
# spec/dummy/db/migrate/. Since we copy engine migrations to the dummy app via
# railties:install:migrations, we remove the engine source path to avoid
# duplicates and ordering problems.
Rake::Task["app:db:load_config"].enhance do
  engine_migrate = File.expand_path("db/migrate", ENGINE_ROOT)
  ActiveRecord::Tasks::DatabaseTasks.migrations_paths.delete(engine_migrate)
end

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(spec: "app:db:test:prepare")

task default: :spec
