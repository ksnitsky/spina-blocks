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

      # Render a single block using its block_template partial.
      # An optional content block is forwarded to the partial, so block
      # templates can expose `<%= yield %>` slots for callers to inject markup.
      # Usage:
      #   <%= render_block(some_block) %>
      #   <%= render_block(some_block) do %>...<% end %>
      def render_block(block, &content_block)
        return unless block&.active?

        current_spina_theme = Spina::Current.theme || current_theme
        theme_name = current_spina_theme.name.parameterize.underscore

        partial_path = "#{theme_name}/blocks/#{block.block_template}"

        if lookup_context.exists?(partial_path, [], true)
          # Use the string-form `render(string, locals, &block)` so passing a
          # content block doesn't trigger `render`'s implicit layout branch
          # (which would treat `:partial` as the wrapped content instead).
          render(partial_path, { block: block }, &content_block)
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

      # Render a custom (system) block by its unique key
      # Usage:
      #   <%= render_custom_block("header") %>
      #   <%= render_custom_block("header") do %>...<% end %>
      def render_custom_block(key, &content_block)
        block = Spina::Blocks::Block.find_by(key: key)
        render_block(block, &content_block) if block
      end

      private

      def render_block_fallback(block)
        content_tag(:div, class: "spina-block spina-block--#{block.block_template}") do
          content_tag(:p, block.name, class: "spina-block__title")
        end
      end
    end
  end
end
