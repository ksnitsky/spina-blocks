# frozen_string_literal: true

class AddDeletableToSpinaBlocksBlocks < ActiveRecord::Migration[7.0]
  def change
    return if connection.column_exists?(:spina_blocks_blocks, :deletable)

    add_column(:spina_blocks_blocks, :deletable, :boolean, default: true, null: false)
  end
end
