# frozen_string_literal: true

module Spina
  module Parts
    class BlockCollection < Base
      attr_json :block_ids, :integer, array: true, default: -> { [] }

      attr_accessor :options

      # Defense: strip nils, zeros, and blanks that may sneak in from form submissions
      def block_ids=(value)
        super(Array(value).reject(&:blank?).map(&:to_i).reject(&:zero?).uniq)
      end

      def content
        return [] if block_ids.blank?

        blocks_by_id = ::Spina::Blocks::Block.active.where(id: block_ids).index_by(&:id)
        block_ids.filter_map { |id| blocks_by_id[id] }
      end
    end
  end
end
