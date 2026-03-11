# frozen_string_literal: true

class CreateSpinaBlocksPageBlocks < ActiveRecord::Migration[7.0]
  def change
    create_table :spina_blocks_page_blocks do |t|
      t.references :page, null: false, foreign_key: { to_table: :spina_pages }
      t.references :block, null: false, foreign_key: { to_table: :spina_blocks_blocks }
      t.integer :position, default: 0

      t.timestamps
    end

    add_index :spina_blocks_page_blocks, %i[page_id block_id], unique: true
  end
end
