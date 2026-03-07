class CreateSpinaBlocks < ActiveRecord::Migration[7.0]
  def change
    create_table :spina_blocks do |t|
      t.string :title, null: false
      t.string :name, null: false
      t.string :block_template, null: false
      t.references :block_category, foreign_key: { to_table: :spina_block_categories }, null: true
      t.integer :position, default: 0
      t.boolean :active, default: true
      t.json :json_attributes

      t.timestamps
    end

    add_index :spina_blocks, :name, unique: true
  end
end
