# frozen_string_literal: true

require 'spec_helper'

ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('dummy/config/environment', __dir__)

abort('The Rails environment is running in production mode!') if Rails.env.production?

require 'rspec/rails'
require 'factory_bot_rails'

# Load support files
Dir[File.join(__dir__, 'support', '**', '*.rb')].each { |f| require f }

# Set up migration paths for engine testing.
# Replace the default relative path with absolute engine paths to avoid
# duplicates when running from the gem root directory.
ActiveRecord::Migrator.migrations_paths.replace([
                                                  Spina::Engine.root.join('db/migrate').to_s,
                                                  Spina::Blocks::Engine.root.join('db/migrate').to_s
                                                ])

# Run pending migrations on the dummy app
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.include FactoryBot::Syntax::Methods
end

# Register factory paths (gem root spec/factories, not dummy app)
FactoryBot.definition_file_paths = [File.join(__dir__, 'factories')]
FactoryBot.find_definitions
