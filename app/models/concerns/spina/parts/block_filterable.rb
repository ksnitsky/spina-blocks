# frozen_string_literal: true

module Spina
  module Parts
    module BlockFilterable
      extend ActiveSupport::Concern

      def available_blocks
        scope = ::Spina::Blocks::Block.active.sorted
        opts = options.is_a?(Hash) ? options.with_indifferent_access : nil
        if opts&.dig(:block_template).present?
          scope = scope.where(block_template: opts[:block_template])
        end
        scope
      end
    end
  end
end
