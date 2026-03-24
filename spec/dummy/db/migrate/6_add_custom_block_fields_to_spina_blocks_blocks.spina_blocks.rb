# frozen_string_literal: true

class AddCustomBlockFieldsToSpinaBlocksBlocks < ActiveRecord::Migration[7.0]
  def change
    unless connection.column_exists?(:spina_blocks_blocks, :deletable)
      add_column(:spina_blocks_blocks, :deletable, :boolean, default: true, null: false)
    end

    unless connection.column_exists?(:spina_blocks_blocks, :key)
      add_column(:spina_blocks_blocks, :key, :string)
      add_index(:spina_blocks_blocks, :key, unique: true, where: "key IS NOT NULL")
    end
  end
end
