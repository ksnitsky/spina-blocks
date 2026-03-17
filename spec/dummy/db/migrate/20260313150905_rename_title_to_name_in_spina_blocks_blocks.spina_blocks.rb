# frozen_string_literal: true

# This migration comes from spina_blocks (originally 5)
class RenameTitleToNameInSpinaBlocksBlocks < ActiveRecord::Migration[7.0]
  def change
    # For fresh installs: migration 2 already creates only `name`, no `title`.
    return unless connection.column_exists?(:spina_blocks_blocks, :title)

    # Edge case: both `title` and `name` exist (migration 2 ran with both
    # columns but migration 4, which removed `name`, was never executed).
    if connection.column_exists?(:spina_blocks_blocks, :name)
      remove_index(:spina_blocks_blocks, :name) if connection.index_exists?(:spina_blocks_blocks, :name)
      remove_column(:spina_blocks_blocks, :name, :string)
    end

    rename_column(:spina_blocks_blocks, :title, :name)
    add_index(:spina_blocks_blocks, :name, unique: true)
  end
end
