module Spina
  module Parts
    class BlockCollection < Base
      attr_json :block_ids, :integer, array: true, default: -> { [] }

      attr_accessor :options

      def content
        return [] if block_ids.blank?

        blocks_by_id = ::Spina::Blocks::Block.active.where(id: block_ids).index_by(&:id)
        block_ids.filter_map { |id| blocks_by_id[id] }
      end
    end
  end
end
