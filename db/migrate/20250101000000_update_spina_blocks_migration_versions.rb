# frozen_string_literal: true

class UpdateSpinaBlocksMigrationVersions < ActiveRecord::Migration[7.0]
  VERSIONS_MAPPING = {
    '1' => '20250101000001',
    '2' => '20250101000002',
    '3' => '20250101000003',
    '4' => '20250101000004'
  }.freeze

  def up
    VERSIONS_MAPPING.each do |old_version, new_version|
      execute <<~SQL.squish
        UPDATE schema_migrations
        SET version = '#{new_version}'
        WHERE version = '#{old_version}'
      SQL
    end
  end

  def down
    # no-op: reverting to numbered migrations is not supported
  end
end
