# frozen_string_literal: true

class CreateSpinaBlocksBlocks < ActiveRecord::Migration[7.0]
  def change
    if legacy_migration_applied?
      cleanup_legacy_version!
      return
    end

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

  def legacy_migration_applied?
    ActiveRecord::Base.connection
                      .select_value("SELECT 1 FROM schema_migrations WHERE version = '2'")
  end

  def cleanup_legacy_version!
    execute "DELETE FROM schema_migrations WHERE version = '2'"
  end
end
