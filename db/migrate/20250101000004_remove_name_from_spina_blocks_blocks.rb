# frozen_string_literal: true

class RemoveNameFromSpinaBlocksBlocks < ActiveRecord::Migration[7.0]
  def change
    if legacy_migration_applied?
      cleanup_legacy_version!
      return
    end

    remove_index :spina_blocks_blocks, :name
    remove_column :spina_blocks_blocks, :name, :string
  end

  private

  def legacy_migration_applied?
    ActiveRecord::Base.connection
                      .select_value("SELECT 1 FROM schema_migrations WHERE version = '4'")
  end

  def cleanup_legacy_version!
    execute "DELETE FROM schema_migrations WHERE version = '4'"
  end
end
