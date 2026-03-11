# frozen_string_literal: true

class RemoveNameFromSpinaBlocksBlocks < ActiveRecord::Migration[7.0]
  def change
    remove_index :spina_blocks_blocks, :name
    remove_column :spina_blocks_blocks, :name, :string
  end
end
