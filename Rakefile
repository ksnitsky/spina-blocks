# frozen_string_literal: true

require 'bundler/setup'
require 'bundler/gem_tasks'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

task default: :spec

namespace :db do
  namespace :test do
    desc 'Set up the test database (create, migrate Spina + spina-blocks tables)'
    task :prepare do
      ENV['RAILS_ENV'] = 'test'
      require File.expand_path('spec/dummy/config/environment', __dir__)

      # Create database if it doesn't exist
      begin
        ActiveRecord::Tasks::DatabaseTasks.create_current
      rescue ActiveRecord::DatabaseAlreadyExists
        # Already exists, continue
      end

      # Set up migration paths
      ActiveRecord::Migrator.migrations_paths.replace([
        Spina::Engine.root.join('db/migrate').to_s
      ])

      # Run Spina migrations
      ActiveRecord::Tasks::DatabaseTasks.migrate

      conn = ActiveRecord::Base.connection

      # Create spina-blocks tables directly to avoid legacy migration version conflicts
      # (spina-blocks migrations check for versions 1-4 in schema_migrations,
      # which overlap with Spina's own migration versions)
      unless conn.table_exists?(:spina_blocks_categories)
        conn.create_table :spina_blocks_categories do |t|
          t.string :name, null: false
          t.string :label, null: false
          t.integer :position, default: 0
          t.timestamps
        end
        conn.add_index :spina_blocks_categories, :name, unique: true
      end

      unless conn.table_exists?(:spina_blocks_blocks)
        conn.create_table :spina_blocks_blocks do |t|
          t.string :title, null: false
          t.string :block_template, null: false
          t.references :category, foreign_key: { to_table: :spina_blocks_categories }, null: true
          t.integer :position, default: 0
          t.boolean :active, default: true
          t.json :json_attributes
          t.timestamps
        end
      end

      unless conn.table_exists?(:spina_blocks_page_blocks)
        conn.create_table :spina_blocks_page_blocks do |t|
          t.references :page, null: false, foreign_key: { to_table: :spina_pages }
          t.references :block, null: false, foreign_key: { to_table: :spina_blocks_blocks }
          t.integer :position, default: 0
          t.timestamps
        end
        conn.add_index :spina_blocks_page_blocks, %i[page_id block_id], unique: true
      end

      # Mark spina-blocks migrations as completed
      %w[20250101000001 20250101000002 20250101000003 20250101000004].each do |version|
        unless conn.select_value("SELECT 1 FROM schema_migrations WHERE version = #{conn.quote(version)}")
          conn.execute("INSERT INTO schema_migrations (version) VALUES (#{conn.quote(version)})")
        end
      end

      # Set final migration paths
      ActiveRecord::Migrator.migrations_paths.replace([
        Spina::Engine.root.join('db/migrate').to_s,
        Spina::Blocks::Engine.root.join('db/migrate').to_s
      ])

      puts 'Test database is ready.'
    end
  end
end
