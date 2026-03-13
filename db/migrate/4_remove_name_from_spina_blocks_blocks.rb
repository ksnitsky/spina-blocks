# frozen_string_literal: true

class RemoveNameFromSpinaBlocksBlocks < ActiveRecord::Migration[7.0]
  def change
    if previous_version_applied?("20250101000004")
      cleanup_version!("20250101000004")
      return
    end

    return unless connection.column_exists?(:spina_blocks_blocks, :name)

    remove_index(:spina_blocks_blocks, :name)
    remove_column(:spina_blocks_blocks, :name, :string)
  end

  private

  def previous_version_applied?(version)
    connection.select_value(
      "SELECT 1 FROM schema_migrations WHERE version = #{connection.quote(version)}",
    )
  end

  def cleanup_version!(version)
    connection.execute(
      "DELETE FROM schema_migrations WHERE version = #{connection.quote(version)}",
    )
  end
end
