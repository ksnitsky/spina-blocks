# frozen_string_literal: true

class CreateSpinaBlocksBlocks < ActiveRecord::Migration[7.0]
  def change
    if previous_version_applied?('20250101000002')
      cleanup_version!('20250101000002')
      return
    end

    return if connection.table_exists?(:spina_blocks_blocks)

    create_table :spina_blocks_blocks do |t|
      t.string :title, null: false
      t.string :name, null: false
      t.string :block_template, null: false
      t.references :category, foreign_key: { to_table: :spina_blocks_categories }, null: true
      t.integer :position, default: 0
      t.boolean :active, default: true
      t.json :json_attributes

      t.timestamps
    end

    add_index :spina_blocks_blocks, :name, unique: true
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
