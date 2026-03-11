# frozen_string_literal: true

class CreateSpinaBlocksCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :spina_blocks_categories do |t|
      t.string :name, null: false
      t.string :label, null: false
      t.integer :position, default: 0

      t.timestamps
    end

    add_index :spina_blocks_categories, :name, unique: true
  end
end
