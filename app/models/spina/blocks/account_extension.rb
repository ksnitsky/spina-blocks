# frozen_string_literal: true

module Spina
  module Blocks
    module AccountExtension
      extend ActiveSupport::Concern

      included do
        after_save :bootstrap_block_categories
      end

      private

      def bootstrap_block_categories
        theme_config = Spina::Theme.find_by_name(theme)
        return unless theme_config
        return unless theme_config.respond_to?(:block_categories) && theme_config.block_categories.present?

        theme_config.block_categories.each_with_index do |category, index|
          Spina::Blocks::Category.where(name: category[:name])
            .first_or_create(label: category[:label])
            .update(label: category[:label], position: index)
        end
      end
    end
  end
end
