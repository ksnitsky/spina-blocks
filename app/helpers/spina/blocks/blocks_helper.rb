# frozen_string_literal: true

module Spina
  module Blocks
    module BlocksHelper
      # Render all blocks attached to the current page via PageBlocks
      # Usage in a page template: <%= render_blocks %>
      def render_blocks(page = nil)
        page ||= current_page
        return unless page.respond_to?(:page_blocks)

        page.page_blocks.sorted.includes(:block).each do |page_block|
          block = page_block.block
          next unless block&.active?

          concat(render_block(block))
        end
      end

      # Render a single block using its block_template partial
      # Usage: <%= render_block(some_block) %>
      def render_block(block)
        return unless block&.active?

        current_spina_theme = Spina::Current.theme || current_theme
        theme_name = current_spina_theme.name.parameterize.underscore

        partial_path = "#{theme_name}/blocks/#{block.block_template}"

        if lookup_context.exists?(partial_path, [], true)
          render(partial: partial_path, locals: { block: block })
        else
          render_block_fallback(block)
        end
      end

      # Access a block's content like page content
      # Usage in block partial: block_content(block, :headline)
      def block_content(block, part_name = nil)
        block.content(part_name)
      end

      # Check if a block has content for a given part
      def block_has_content?(block, part_name)
        block.has_content?(part_name)
      end

      private

      def render_block_fallback(block)
        content_tag(:div, class: "spina-block spina-block--#{block.block_template}") do
          content_tag(:p, block.title, class: "spina-block__title")
        end
      end
    end
  end
end
