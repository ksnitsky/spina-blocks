# frozen_string_literal: true

class CreateSpinaBlocksPageBlocks < ActiveRecord::Migration[7.0]
  def change
    if previous_version_applied?('20250101000003')
      cleanup_version!('20250101000003')
      return
    end

    return if connection.table_exists?(:spina_blocks_page_blocks)

    create_table :spina_blocks_page_blocks do |t|
      t.references :page, null: false, foreign_key: { to_table: :spina_pages }
      t.references :block, null: false, foreign_key: { to_table: :spina_blocks_blocks }
      t.integer :position, default: 0

      t.timestamps
    end

    add_index :spina_blocks_page_blocks, %i[page_id block_id], unique: true
  end

  private

  def previous_version_applied?(version)
    connection.select_value(
      "SELECT 1 FROM schema_migrations WHERE version = #{connection.quote(version)}"
    )
  end

  def cleanup_version!(version)
    connection.execute(
      "DELETE FROM schema_migrations WHERE version = #{connection.quote(version)}"
    )
  end
end
