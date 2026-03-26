# frozen_string_literal: true

module Spina
  module Blocks
    module AccountExtension
      extend ActiveSupport::Concern

      included do
        after_save :bootstrap_block_categories
        after_save :bootstrap_custom_blocks
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

      def bootstrap_custom_blocks
        theme_config = Spina::Theme.find_by_name(theme)
        return unless theme_config
        return unless theme_config.respond_to?(:custom_blocks) && theme_config.custom_blocks.present?

        theme_config.custom_blocks.each do |block_config|
          category = if block_config[:category].present?
            Spina::Blocks::Category.find_by(name: block_config[:category])
          end

          display_name = block_config[:title].presence || block_config[:name].to_s.titleize

          block = Spina::Blocks::Block
            .where(key: block_config[:name])
            .first_or_initialize

          block.assign_attributes(
            name: block.persisted? ? block.name : display_name,
            block_template: block_config[:block_template],
            category: category,
            deletable: false,
            active: block.persisted? ? block.active : true,
          )

          # Set key only on new records (it is immutable after creation)
          block.key = block_config[:name] unless block.persisted?

          block.save!
        end
      end
    end
  end
end
