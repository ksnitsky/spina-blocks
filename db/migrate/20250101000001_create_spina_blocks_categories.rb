# frozen_string_literal: true

class CreateSpinaBlocksCategories < ActiveRecord::Migration[7.0]
  def change
    if legacy_migration_applied?
      cleanup_legacy_version!
      return
    end

    create_table :spina_blocks_categories do |t|
      t.string :name, null: false
      t.string :label, null: false
      t.integer :position, default: 0

      t.timestamps
    end

    add_index :spina_blocks_categories, :name, unique: true
  end

  private

  def legacy_migration_applied?
    ActiveRecord::Base.connection
                      .select_value("SELECT 1 FROM schema_migrations WHERE version = '1'")
  end

  def cleanup_legacy_version!
    execute "DELETE FROM schema_migrations WHERE version = '1'"
  end
end
