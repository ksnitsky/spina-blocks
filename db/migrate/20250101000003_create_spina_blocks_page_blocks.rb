# frozen_string_literal: true

class CreateSpinaBlocksPageBlocks < ActiveRecord::Migration[7.0]
  def change
    if legacy_migration_applied?
      cleanup_legacy_version!
      return
    end

    create_table :spina_blocks_page_blocks do |t|
      t.references :page, null: false, foreign_key: { to_table: :spina_pages }
      t.references :block, null: false, foreign_key: { to_table: :spina_blocks_blocks }
      t.integer :position, default: 0

      t.timestamps
    end

    add_index :spina_blocks_page_blocks, %i[page_id block_id], unique: true
  end

  private

  def legacy_migration_applied?
    ActiveRecord::Base.connection
                      .select_value("SELECT 1 FROM schema_migrations WHERE version = '3'")
  end

  def cleanup_legacy_version!
    execute "DELETE FROM schema_migrations WHERE version = '3'"
  end
end
