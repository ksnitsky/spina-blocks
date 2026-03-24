# frozen_string_literal: true

class AddKeyToSpinaBlocksBlocks < ActiveRecord::Migration[7.0]
  def change
    return if connection.column_exists?(:spina_blocks_blocks, :key)

    add_column(:spina_blocks_blocks, :key, :string)
    add_index(:spina_blocks_blocks, :key, unique: true, where: "key IS NOT NULL")
  end
end
