# frozen_string_literal: true

module Spina
  module Parts
    class BlockReference < Base
      include BlockFilterable
      include AttrJson::NestedAttributes

      attr_json :block_id, :integer, default: nil
      # "reference" (default): points at a shared block via block_id / custom_block.
      # "inline": content is filled in and stored on the page itself.
      attr_json :mode, :string, default: nil
      # Inline content, used when mode == "inline". Same shape as a Section's
      # content: a RepeaterContent holding the block template's parts.
      attr_json :inline_content, RepeaterContent.to_type, default: nil
      attr_json_accepts_nested_attributes_for :inline_content

      attr_accessor :options

      def content
        return inline_block if inline?

        if custom_block_name.present?
          custom_block_record
        else
          ::Spina::Blocks::Block.active.find_by(id: block_id)
        end
      end

      # Whether this reference is filled inline (page-local) instead of pointing
      # at a shared block. Absent/blank mode is treated as "reference" so existing
      # parts stay backward compatible.
      def inline?
        mode.to_s == "inline"
      end

      # The block template this reference is bound to (from part options). Drives
      # both the reference-mode filter and the inline-mode field set.
      def block_template_name
        return if options.blank?

        options[:block_template] || options["block_template"]
      end

      # Returns the custom_block key from options, supporting both symbol and string keys
      def custom_block_name
        return if options.blank?

        options[:custom_block] || options["custom_block"]
      end

      # Looks up the custom block record by key
      def custom_block_record
        return if custom_block_name.blank?

        ::Spina::Blocks::Block.find_by(key: custom_block_name)
      end

      private

      # Wraps inline content so it renders through the same block template partial
      # as a shared block. Returns nil when nothing has been filled in, so callers
      # using `render_block(content)` render nothing (matching an empty reference).
      def inline_block
        return nil if inline_content.blank?

        parts = Array(inline_content.parts)
        return nil if parts.none? { |part| part.content.present? }

        ::Spina::Blocks::InlineBlock.new(inline_content, block_template_name)
      end
    end
  end
end
