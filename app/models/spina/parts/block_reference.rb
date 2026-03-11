# frozen_string_literal: true

module Spina
  module Parts
    class BlockReference < Base
      attr_json :block_id, :integer, default: nil

      attr_accessor :options

      def content
        ::Spina::Blocks::Block.active.find_by(id: block_id)
      end
    end
  end
end
